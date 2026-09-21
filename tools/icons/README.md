# App icon

`assets/icon/app_icon.png` is the master: the icon artwork on a rounded square,
1024x1024 RGBA, transparent outside the rounded square. It is the only file to
edit when the icon changes.

- `python3 tools/icons/generate_icons.py` regenerates every Android, iOS and web
  icon from the master. Requires `pillow` and `numpy`.
- `python3 tools/icons/trim_master.py <render.png>` rebuilds the master from a
  render of the icon on a black background (crops it, drops the antialiased rim
  and turns the rounded corners back into transparency).

The master is not listed in `pubspec.yaml`, so it is not bundled into the app —
it is a source file for the generator only.
