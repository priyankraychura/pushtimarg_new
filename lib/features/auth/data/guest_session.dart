import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// A guest session that lives on the device only.
///
/// "Continue without an account" normally signs in anonymously with Firebase,
/// which keeps Firestore reachable for the guest. When that is unavailable —
/// the Anonymous provider is switched off for the project, or the phone is
/// offline — the guest would otherwise be stuck on the sign-in screen, so the
/// repository falls back to a session recorded here instead. Guests keep their
/// favourites and reading position locally either way, so nothing is lost.
class GuestSessionStore {
  GuestSessionStore(this._prefs);

  static const _key = 'auth.local_guest';

  final SharedPreferences _prefs;
  final _changes = StreamController<bool>.broadcast();

  bool get active => _prefs.getBool(_key) ?? false;

  /// Emits whenever [active] flips, so the auth stream can re-publish.
  Stream<bool> get changes => _changes.stream;

  Future<void> start() => _set(true);

  Future<void> clear() => active ? _set(false) : Future<void>.value();

  Future<void> _set(bool value) async {
    await _prefs.setBool(_key, value);
    if (!_changes.isClosed) _changes.add(value);
  }

  void dispose() => _changes.close();
}
