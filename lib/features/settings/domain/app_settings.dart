import 'package:flutter/material.dart';

import '../../lyrics/domain/lyrics.dart';

enum AutoScrollSpeed {
  slow('Slow', 28),
  medium('Medium', 40),
  fast('Fast', 60);

  const AutoScrollSpeed(this.label, this.pixelsPerSecond);
  final String label;
  final double pixelsPerSecond;
}

/// Everything the Settings screen edits. Persisted as a flat key/value map.
@immutable
class AppSettings {
  const AppSettings({
    this.script = Script.gujarati,
    this.textScale = 1.0,
    this.autoScrollEnabled = false,
    this.autoScroll = AutoScrollSpeed.medium,
    this.keepAwake = true,
    this.themeMode = ThemeMode.system,
    this.remindBeforeSeva = true,
    this.reminderMinutes = 10,
    this.showTithi = true,
    this.sevaTimes = const {},
  });

  final Script script;

  /// 0.8 – 1.6, applied to lyric text only.
  final double textScale;

  /// Shows the Auto-scroll button in the reader. Off by default.
  final bool autoScrollEnabled;
  final AutoScrollSpeed autoScroll;
  final bool keepAwake;
  final ThemeMode themeMode;
  final bool remindBeforeSeva;
  final int reminderMinutes;
  final bool showTithi;

  /// Seva name → "HH:mm". Empty = use `AppConfig.defaultSevaTimes`.
  final Map<String, String> sevaTimes;

  AppSettings copyWith({
    Script? script,
    double? textScale,
    bool? autoScrollEnabled,
    AutoScrollSpeed? autoScroll,
    bool? keepAwake,
    ThemeMode? themeMode,
    bool? remindBeforeSeva,
    int? reminderMinutes,
    bool? showTithi,
    Map<String, String>? sevaTimes,
  }) =>
      AppSettings(
        script: script ?? this.script,
        textScale: textScale ?? this.textScale,
        autoScrollEnabled: autoScrollEnabled ?? this.autoScrollEnabled,
        autoScroll: autoScroll ?? this.autoScroll,
        keepAwake: keepAwake ?? this.keepAwake,
        themeMode: themeMode ?? this.themeMode,
        remindBeforeSeva: remindBeforeSeva ?? this.remindBeforeSeva,
        reminderMinutes: reminderMinutes ?? this.reminderMinutes,
        showTithi: showTithi ?? this.showTithi,
        sevaTimes: sevaTimes ?? this.sevaTimes,
      );

  Map<String, Object> toMap() => {
        'script': script.key,
        'textScale': textScale,
        'autoScrollEnabled': autoScrollEnabled,
        'autoScroll': autoScroll.name,
        'keepAwake': keepAwake,
        'themeMode': themeMode.name,
        'remindBeforeSeva': remindBeforeSeva,
        'reminderMinutes': reminderMinutes,
        'showTithi': showTithi,
        'sevaTimes': sevaTimes.entries.map((e) => '${e.key}=${e.value}').join(';'),
      };

  factory AppSettings.fromMap(Map<String, Object?> m) {
    final seva = <String, String>{};
    for (final pair in (m['sevaTimes'] as String? ?? '').split(';')) {
      final i = pair.indexOf('=');
      if (i > 0) seva[pair.substring(0, i)] = pair.substring(i + 1);
    }
    return AppSettings(
      script: Script.fromKey(m['script'] as String?),
      textScale: (m['textScale'] as num?)?.toDouble() ?? 1.0,
      autoScrollEnabled: m['autoScrollEnabled'] as bool? ?? false,
      autoScroll: AutoScrollSpeed.values.firstWhere(
        (s) => s.name == m['autoScroll'],
        orElse: () => AutoScrollSpeed.medium,
      ),
      keepAwake: m['keepAwake'] as bool? ?? true,
      themeMode: ThemeMode.values.firstWhere(
        (t) => t.name == m['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      remindBeforeSeva: m['remindBeforeSeva'] as bool? ?? true,
      reminderMinutes: (m['reminderMinutes'] as num?)?.toInt() ?? 10,
      showTithi: m['showTithi'] as bool? ?? true,
      sevaTimes: seva,
    );
  }
}
