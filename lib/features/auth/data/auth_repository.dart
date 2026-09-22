import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/app_user.dart';
import 'guest_session.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> registerWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInAsGuest();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

// ---------------------------------------------------------------------------
// Firebase
// ---------------------------------------------------------------------------

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._guests);

  /// The guest the app falls back to when Firebase will not hand out an
  /// anonymous session (see [signInAsGuest]).
  static const localGuest = AppUser(
    uid: 'local-guest',
    isAnonymous: true,
    isLocalGuest: true,
    provider: AuthProviderKind.anonymous,
  );

  /// Firebase codes that mean "no anonymous session for you" rather than
  /// "something went wrong". None of them are worth blocking a guest over:
  /// a guest keeps everything on the device anyway.
  static const _guestFallbackCodes = {
    'admin-restricted-operation', // Anonymous provider switched off
    'operation-not-allowed', // Same, older SDK wording
    'configuration-not-found', // Auth not enabled for the project
    'network-request-failed', // Offline
  };

  final fb.FirebaseAuth _auth;
  final GuestSessionStore _guests;
  bool _googleReady = false;

  /// Firebase's own user, or the local guest when one is running. Both
  /// sources have to be watched: the guest flag flips without Firebase
  /// hearing about it, and signing in for real clears the flag.
  @override
  Stream<AppUser?> authStateChanges() {
    late StreamController<AppUser?> out;
    StreamSubscription<fb.User?>? authSub;
    StreamSubscription<bool>? guestSub;
    fb.User? user;
    var seeded = false;

    void emit() {
      // Hold off until Firebase has reported once, so a stored guest flag
      // cannot beat a real signed-in user to the router.
      if (seeded && !out.isClosed) out.add(_map(user) ?? (_guests.active ? localGuest : null));
    }

    out = StreamController<AppUser?>(
      onListen: () {
        authSub = _auth.authStateChanges().listen((u) {
          user = u;
          seeded = true;
          emit();
        });
        guestSub = _guests.changes.listen((_) => emit());
      },
      onCancel: () async {
        await authSub?.cancel();
        await guestSub?.cancel();
      },
    );
    return out.stream;
  }

  @override
  AppUser? get currentUser => _map(_auth.currentUser) ?? (_guests.active ? localGuest : null);

  @override
  Future<AppUser> signInWithEmail(String email, String password) => _guard(() async {
        final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
        await _guests.clear();
        return _map(cred.user)!;
      });

  @override
  Future<AppUser> registerWithEmail(String email, String password) => _guard(() async {
        // If the current session is a guest, keep their data by linking.
        final current = _auth.currentUser;
        final credential = fb.EmailAuthProvider.credential(email: email.trim(), password: password);
        final cred = current != null && current.isAnonymous
            ? await current.linkWithCredential(credential)
            : await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        await _guests.clear();
        return _map(cred.user)!;
      });

  @override
  Future<AppUser> signInWithGoogle() => _guard(() async {
        // On web Firebase's popup flow works without a client-id meta tag.
        if (kIsWeb) {
          final cred = await _auth.signInWithPopup(fb.GoogleAuthProvider());
          await _guests.clear();
          return _map(cred.user)!;
        }
        final google = GoogleSignIn.instance;
        if (!_googleReady) {
          await google.initialize();
          _googleReady = true;
        }
        final account = await google.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) throw const AuthException('Google sign-in did not return a token.');
        final credential = fb.GoogleAuthProvider.credential(idToken: idToken);

        final current = _auth.currentUser;
        final cred = current != null && current.isAnonymous
            ? await current.linkWithCredential(credential)
            : await _auth.signInWithCredential(credential);
        await _guests.clear();
        return _map(cred.user)!;
      });

  /// Anonymous Firebase session when the project offers one, otherwise a
  /// device-local guest. Falling back matters: with the Anonymous provider
  /// switched off, `signInAnonymously` fails with `admin-restricted-operation`
  /// and "Continue without an account" leaves the user on the sign-in screen
  /// with nothing but an error code.
  @override
  Future<AppUser> signInAsGuest() async {
    try {
      final cred = await _auth.signInAnonymously();
      await _guests.clear();
      return _map(cred.user)!;
    } on fb.FirebaseAuthException catch (e) {
      if (!_guestFallbackCodes.contains(e.code)) {
        throw AuthException(_message(e.code), code: e.code);
      }
      await _guests.start();
      return localGuest;
    }
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() async {
    await _guests.clear();
    await _auth.signOut();
    if (_googleReady && !kIsWeb) await GoogleSignIn.instance.signOut();
  }

  AppUser? _map(fb.User? u) {
    if (u == null) return null;
    final providers = u.providerData.map((p) => p.providerId).toSet();
    return AppUser(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      photoUrl: u.photoURL,
      isAnonymous: u.isAnonymous,
      provider: u.isAnonymous
          ? AuthProviderKind.anonymous
          : providers.contains('google.com')
              ? AuthProviderKind.google
              : AuthProviderKind.email,
    );
  }

  /// Converts Firebase error codes into the plain-English copy from the design.
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code), code: e.code);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.', code: 'canceled');
      }
      throw AuthException('Google sign-in failed: ${e.description ?? e.code.name}');
    }
  }

  static String _message(String code) => switch (code) {
        'wrong-password' || 'invalid-credential' => "That password doesn't match this email.",
        'user-not-found' => 'No account with that email — create one instead.',
        'email-already-in-use' => 'You already have an account — sign in instead.',
        'weak-password' => 'Use at least 8 characters.',
        'invalid-email' => 'That email address doesn\'t look right.',
        'too-many-requests' => 'Too many attempts. Try again in a few minutes.',
        'network-request-failed' => 'No connection. Check your internet and try again.',
        'credential-already-in-use' => 'That account is already linked to another user.',
        'operation-not-allowed' || 'admin-restricted-operation' =>
          'That sign-in method is turned off for this app.',
        _ => 'Something went wrong ($code). Please try again.',
      };
}

// ---------------------------------------------------------------------------
// Demo (no Firebase configured)
// ---------------------------------------------------------------------------

class DemoAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  Future<AppUser> _set(AppUser u) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _user = u;
    _controller.add(u);
    return u;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) {
    if (password.length < 8) throw const AuthException("That password doesn't match this email.");
    return _set(AppUser(uid: 'demo-email', email: email, provider: AuthProviderKind.email));
  }

  @override
  Future<AppUser> registerWithEmail(String email, String password) {
    if (password.length < 8) throw const AuthException('Use at least 8 characters.');
    return _set(AppUser(uid: 'demo-email', email: email, provider: AuthProviderKind.email));
  }

  @override
  Future<AppUser> signInWithGoogle() => _set(const AppUser(
        uid: 'demo-google',
        email: 'priyank@example.com',
        displayName: 'Priyank',
        provider: AuthProviderKind.google,
      ));

  @override
  Future<AppUser> signInAsGuest() =>
      _set(const AppUser(uid: 'demo-guest', isAnonymous: true, provider: AuthProviderKind.anonymous));

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}
