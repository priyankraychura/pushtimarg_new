import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../../bhajans/data/seed.dart';
import '../../calendar/data/seed_tithi.dart';
import '../../bhajans/providers/bhajan_providers.dart';
import '../../lyrics/domain/lyrics.dart';
import '../domain/app_settings.dart';
import '../providers/settings_providers.dart';
import 'widgets/settings_row.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final sevaTimes = ref.watch(sevaTimesProvider);
    final count = ref.watch(allBhajansProvider).value?.length ?? 0;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: context.safe.top + 14, bottom: AppSpacing.navClearance),
        children: [
          Padding(
            padding: AppSpacing.pageH,
            child: Text('Settings', style: AppTypography.displayMedium.copyWith(fontSize: 30, color: c.ink)),
          ),
          Gap.lg,
          Padding(
            padding: AppSpacing.pageH,
            child: AppCard(
              radius: AppRadius.xxl,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AppAvatar(name: user?.name ?? '?', size: AppSizes.avatarLarge, photoUrl: user?.photoUrl),
                  Gap.md,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Guest', style: AppTypography.titleMedium.copyWith(color: c.ink)),
                        Text(user?.providerLabel ?? '', style: AppTypography.caption.copyWith(fontSize: 12.5, color: c.ink3)),
                      ],
                    ),
                  ),
                  if (user != null && !user.isAnonymous)
                    AppChip(label: 'Synced', tone: AppChipTone.accent, leading: _dot(c.accent)),
                ],
              ),
            ),
          ),

          SettingsGroup(label: 'Reading', children: [
            SettingsRow(
              icon: Icons.translate_rounded,
              tone: IconTileTone.accent,
              label: 'Script',
              description: 'Lyrics shown in',
              value: s.script.label,
              onTap: () => _pick<Script>(context, 'Script', Script.values, s.script, (v) => v.label, notifier.setScript),
            ),
            SettingsRow(
              icon: Icons.format_size_rounded,
              tone: IconTileTone.accent,
              label: 'Text size',
              chevron: false,
              trailing: SizedBox(
                width: 150,
                child: Row(
                  children: [
                    Text('A', style: AppTypography.labelMedium.copyWith(color: c.ink3)),
                    Expanded(
                      child: Slider(
                        value: s.textScale,
                        min: .8,
                        max: 1.6,
                        divisions: 8,
                        onChanged: notifier.setTextScale,
                      ),
                    ),
                    Text('A', style: AppTypography.titleLarge.copyWith(color: c.ink3)),
                  ],
                ),
              ),
            ),
            SettingsRow.toggle(
              icon: Icons.swap_vert_rounded,
              label: 'Auto-scroll',
              description: 'Show the Auto-scroll button while reading',
              value: s.autoScrollEnabled,
              onChanged: notifier.setAutoScrollEnabled,
            ),
            if (s.autoScrollEnabled)
              SettingsRow(
                icon: Icons.speed_rounded,
                label: 'Auto-scroll speed',
                value: s.autoScroll.label,
                onTap: () => _pick<AutoScrollSpeed>(
                    context, 'Auto-scroll speed', AutoScrollSpeed.values, s.autoScroll, (v) => v.label, notifier.setAutoScroll),
              ),
            SettingsRow.toggle(
              icon: Icons.phone_android_rounded,
              label: 'Keep screen awake',
              description: 'While reading a bhajan',
              value: s.keepAwake,
              onChanged: notifier.setKeepAwake,
            ),
          ]),

          SettingsGroup(label: 'Seva', children: [
            SettingsRow(
              icon: Icons.schedule_rounded,
              tone: IconTileTone.rose,
              label: 'Seva timings',
              description: 'Mangala ${sevaTimes['Mangala']} → Shayan ${sevaTimes['Shayan']}',
              value: s.sevaTimes.isEmpty ? 'Default' : 'Custom',
              onTap: () => _editSevaTimes(context, ref, sevaTimes),
            ),
            SettingsRow.toggle(
              icon: Icons.notifications_outlined,
              tone: IconTileTone.rose,
              label: 'Remind before seva',
              description: '${s.reminderMinutes} minutes before',
              value: s.remindBeforeSeva,
              onChanged: notifier.setRemindBeforeSeva,
            ),
            SettingsRow.toggle(
              icon: Icons.calendar_today_outlined,
              tone: IconTileTone.rose,
              label: 'Show tithi on Home',
              value: s.showTithi,
              onChanged: notifier.setShowTithi,
            ),
          ]),

          SettingsGroup(label: 'Appearance', children: [
            SettingsRow(
              icon: Icons.contrast_rounded,
              label: 'Theme',
              value: switch (s.themeMode) { ThemeMode.system => 'System', ThemeMode.light => 'Light', ThemeMode.dark => 'Dark' },
              onTap: () => _pick<ThemeMode>(context, 'Theme', ThemeMode.values, s.themeMode,
                  (v) => v.name[0].toUpperCase() + v.name.substring(1), notifier.setThemeMode),
            ),
            const SettingsRow(icon: Icons.language_rounded, label: 'App language', value: 'English'),
          ]),

          SettingsGroup(label: 'Content', children: [
            SettingsRow(
              icon: Icons.download_outlined,
              tone: IconTileTone.accent,
              label: 'Offline bhajans',
              description: AppConfig.demoMode ? '$count sample bhajans' : '$count downloaded',
              value: 'Up to date',
              chevron: false,
            ),
            const SettingsRow(icon: Icons.edit_outlined, tone: IconTileTone.accent, label: 'Suggest a bhajan or report a mistake'),
            const SettingsRow(icon: Icons.star_outline_rounded, tone: IconTileTone.accent, label: 'Rate the app'),
            if (kDebugMode && !AppConfig.demoMode) ...[
              SettingsRow(
                icon: Icons.cloud_upload_outlined,
                tone: IconTileTone.accent,
                label: 'Seed sample data',
                description: 'Debug · writes sample bhajans to Firestore',
                onTap: () => _seed(context),
              ),
              SettingsRow(
                icon: Icons.calendar_month_outlined,
                tone: IconTileTone.accent,
                label: 'Seed tithi calendar',
                description: 'Debug · writes the generated tithi table to Firestore',
                onTap: () => _seedTithi(context),
              ),
            ],
          ]),

          Gap.xxl,
          Center(
            child: TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: Text('Sign out', style: AppTypography.labelLarge.copyWith(fontSize: 14, color: c.rose)),
            ),
          ),
          Center(
            child: Text(
              'Version ${AppConfig.version}${AppConfig.demoMode ? ' · demo mode' : ''}',
              style: AppTypography.caption.copyWith(fontSize: 12, color: c.ink3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) =>
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Future<void> _seed(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await seedFirestore();
      messenger.showSnackBar(SnackBar(content: Text('Seeded $n bhajans')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Seed failed: $e')));
    }
  }

  Future<void> _seedTithi(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await seedTithi();
      messenger.showSnackBar(SnackBar(content: Text('Seeded $n tithi days')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Tithi seed failed: $e')));
    }
  }

  Future<void> _pick<T>(
    BuildContext context,
    String title,
    List<T> options,
    T current,
    String Function(T) label,
    ValueChanged<T> onSelect,
  ) async {
    final c = context.colors;
    final picked = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.sm),
              child: Text(title, style: AppTypography.titleLarge.copyWith(color: c.ink)),
            ),
            for (final o in options)
              ListTile(
                title: Text(label(o), style: AppTypography.bodyLarge.copyWith(color: c.ink)),
                trailing: o == current ? Icon(Icons.check_rounded, color: c.accentInk) : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            Gap.sm,
          ],
        ),
      ),
    );
    if (picked != null) onSelect(picked);
  }

  Future<void> _editSevaTimes(BuildContext context, WidgetRef ref, Map<String, String> times) async {
    final c = context.colors;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.sm),
              child: Text('Seva timings', style: AppTypography.titleLarge.copyWith(color: c.ink)),
            ),
            for (final e in times.entries)
              ListTile(
                title: Text(e.key, style: AppTypography.bodyLarge.copyWith(color: c.ink)),
                trailing: Text(e.value, style: AppTypography.bodyMedium.copyWith(color: c.ink2)),
                onTap: () async {
                  final parts = e.value.split(':');
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                  );
                  if (t != null) {
                    final hhmm = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                    await ref.read(settingsProvider.notifier).setSevaTime(e.key, hhmm);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
              ),
            Gap.sm,
          ],
        ),
      ),
    );
  }
}
