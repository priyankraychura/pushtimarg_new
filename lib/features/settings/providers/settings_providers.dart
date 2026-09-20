import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../bhajans/domain/bhajan.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

/// Overridden in `main.dart` once SharedPreferences has loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setScript(Script s) => _update(state.copyWith(script: s));
  Future<void> setTextScale(double v) => _update(state.copyWith(textScale: v.clamp(0.8, 1.6)));
  Future<void> setAutoScrollEnabled(bool v) => _update(state.copyWith(autoScrollEnabled: v));
  Future<void> setAutoScroll(AutoScrollSpeed s) => _update(state.copyWith(autoScroll: s));
  Future<void> setKeepAwake(bool v) => _update(state.copyWith(keepAwake: v));
  Future<void> setThemeMode(ThemeMode m) => _update(state.copyWith(themeMode: m));
  Future<void> setRemindBeforeSeva(bool v) => _update(state.copyWith(remindBeforeSeva: v));
  Future<void> setShowTithi(bool v) => _update(state.copyWith(showTithi: v));
  Future<void> setSevaTime(String seva, String hhmm) =>
      _update(state.copyWith(sevaTimes: {...state.sevaTimes, seva: hhmm}));
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Effective seva schedule: user overrides on top of the defaults.
final sevaTimesProvider = Provider<Map<String, String>>((ref) {
  final custom = ref.watch(settingsProvider.select((s) => s.sevaTimes));
  return {...AppConfig.defaultSevaTimes, ...custom};
});
