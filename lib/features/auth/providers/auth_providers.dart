import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/auth_repository.dart';
import '../data/guest_session.dart';
import '../domain/app_user.dart';

final guestSessionProvider = Provider<GuestSessionStore>((ref) {
  final store = GuestSessionStore(ref.watch(sharedPreferencesProvider));
  ref.onDispose(store.dispose);
  return store;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.demoMode) return DemoAuthRepository();
  return FirebaseAuthRepository(FirebaseAuth.instance, ref.watch(guestSessionProvider));
});

/// Current user (null = signed out). The router listens to this.
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authStateProvider).value,
);

/// True when nothing is signed in with Firebase, so Firestore would refuse
/// every read: demo mode, or a guest running on the device alone. The content
/// repositories serve the bundled bhajans, lyrics, vartas and tithi instead of
/// leaving the app empty.
final useBundledContentProvider = Provider<bool>(
  (ref) => AppConfig.demoMode || (ref.watch(currentUserProvider)?.isLocalGuest ?? false),
);

enum AuthMode { signIn, register }

/// Sign-in screen state: which mode, whether a request is in flight, last error.
class AuthFormState {
  const AuthFormState({this.mode = AuthMode.signIn, this.busy = false, this.error});
  final AuthMode mode;
  final bool busy;
  final String? error;

  AuthFormState copyWith({AuthMode? mode, bool? busy, String? Function()? error}) => AuthFormState(
        mode: mode ?? this.mode,
        busy: busy ?? this.busy,
        error: error != null ? error() : this.error,
      );
}

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void toggleMode() => state = state.copyWith(
        mode: state.mode == AuthMode.signIn ? AuthMode.register : AuthMode.signIn,
        error: () => null,
      );

  Future<bool> submit(String email, String password) => _run(() => state.mode == AuthMode.signIn
      ? _repo.signInWithEmail(email, password)
      : _repo.registerWithEmail(email, password));

  Future<bool> google() => _run(_repo.signInWithGoogle);
  Future<bool> guest() => _run(_repo.signInAsGuest);

  Future<bool> resetPassword(String email) => _run(() => _repo.sendPasswordReset(email));

  Future<void> signOut() => _repo.signOut();

  Future<bool> _run(Future<Object?> Function() action) async {
    state = state.copyWith(busy: true, error: () => null);
    try {
      await action();
      state = state.copyWith(busy: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(busy: false, error: () => e.message);
      return false;
    } catch (e) {
      state = state.copyWith(busy: false, error: () => 'Something went wrong. Please try again.');
      return false;
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFormState>(AuthController.new);
