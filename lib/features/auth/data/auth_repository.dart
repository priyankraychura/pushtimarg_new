import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/app_user.dart';

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
  FirebaseAuthRepository(this._auth);

  final fb.FirebaseAuth _auth;
  bool _googleReady = false;

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signInWithEmail(String email, String password) => _guard(() async {
        final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
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
        return _map(cred.user)!;
      });

  @override
  Future<AppUser> signInWithGoogle() => _guard(() async {
        // On web Firebase's popup flow works without a client-id meta tag.
        if (kIsWeb) {
          final cred = await _auth.signInWithPopup(fb.GoogleAuthProvider());
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
        return _map(cred.user)!;
      });

  @override
  Future<AppUser> signInAsGuest() => _guard(() async {
        final cred = await _auth.signInAnonymously();
        return _map(cred.user)!;
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() async {
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
