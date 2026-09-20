import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// Persists [AppSettings] in SharedPreferences under a single key prefix.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'settings.';

  AppSettings load() {
    final map = <String, Object?>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_prefix)) map[key.substring(_prefix.length)] = _prefs.get(key);
    }
    return AppSettings.fromMap(map);
  }

  Future<void> save(AppSettings s) async {
    for (final e in s.toMap().entries) {
      final k = '$_prefix${e.key}';
      final v = e.value;
      switch (v) {
        case bool b:
          await _prefs.setBool(k, b);
        case int i:
          await _prefs.setInt(k, i);
        case double d:
          await _prefs.setDouble(k, d);
        case String str:
          await _prefs.setString(k, str);
      }
    }
  }
}
