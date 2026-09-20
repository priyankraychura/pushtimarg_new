import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../utils/context_extensions.dart';

/// Marigold initial avatar (Home header, Settings profile).
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.name, this.size = AppSizes.avatar, this.photoUrl});

  final String name;
  final double size;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: .35), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          // Google photo hosts block CORS on web, so let the web build fall
          // back to a plain <img> element; the initial shows if that fails too.
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              width: size,
              height: size,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, _, _) => Text(initial, style: _style(c)),
            )
          : Text(initial, style: _style(c)),
    );
  }

  TextStyle _style(AppColors c) => AppTypography.labelLarge.copyWith(fontSize: size * .38, color: c.onAccent);
}

/// Square tinted icon tile — category grid (46) and settings rows (34).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.size = AppSizes.iconTile,
    this.tone = IconTileTone.brand,
  });

  final IconData icon;
  final double size;
  final IconTileTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg) = switch (tone) {
      IconTileTone.brand => (c.surface2, c.brandText),
      IconTileTone.accent => (c.accentSoft, c.accentInk),
      IconTileTone.rose => (c.roseSoft, c.rose),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.r(size * .3)),
      child: Icon(icon, size: size * .52, color: fg),
    );
  }
}

enum IconTileTone { brand, accent, rose }

/// Circular icon button used in top bars (back, share, favourite).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.background,
    this.size = 40,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: background ?? Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: color ?? c.ink2),
        ),
      ),
    );
  }
}
