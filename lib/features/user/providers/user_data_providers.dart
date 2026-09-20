import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_providers.dart';
import '../../settings/providers/settings_providers.dart';

/// Per-user data: favourites and reading position. Kept locally in
/// SharedPreferences always, and mirrored to `users/{uid}` when signed in
/// with a real account so it follows the user across phones.
class UserData {
  const UserData({this.favourites = const {}, this.progress = const {}});

  final Set<String> favourites;

  /// bhajanId → last read line index.
  final Map<String, int> progress;

  UserData copyWith({Set<String>? favourites, Map<String, int>? progress}) =>
      UserData(favourites: favourites ?? this.favourites, progress: progress ?? this.progress);
}

class UserDataNotifier extends Notifier<UserData> {
  static const _favKey = 'user.favourites';
  static const _progKey = 'user.progress';

  @override
  UserData build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final favs = prefs.getStringList(_favKey)?.toSet() ?? {};
    final raw = prefs.getString(_progKey);
    final prog = raw == null
        ? <String, int>{}
        : Map<String, int>.from(jsonDecode(raw) as Map).map((k, v) => MapEntry(k, v));
    return UserData(favourites: favs, progress: prog);
  }

  Future<void> toggleFavourite(String id) async {
    final next = {...state.favourites};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(favourites: next);
    await _persist();
  }

  Future<void> setProgress(String id, int line) async {
    if (state.progress[id] == line) return;
    state = state.copyWith(progress: {...state.progress, id: line});
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_favKey, state.favourites.toList());
    await prefs.setString(_progKey, jsonEncode(state.progress));

    final user = ref.read(currentUserProvider);
    if (AppConfig.demoMode || user == null || user.isAnonymous) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'favourites': state.favourites.toList(),
      'progress': state.progress,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

final userDataProvider = NotifierProvider<UserDataNotifier, UserData>(UserDataNotifier.new);

final isFavouriteProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(userDataProvider.select((u) => u.favourites.contains(id))),
);
