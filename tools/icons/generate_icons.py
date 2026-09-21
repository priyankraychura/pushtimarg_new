#!/usr/bin/env python3
"""Generate the Android, iOS and web launcher icons from assets/icon/app_icon.png.

Usage: python3 tools/icons/generate_icons.py

The master is a square RGBA image: the icon artwork inside a rounded square,
transparent outside it. Platforms that apply their own mask (iOS, the Android
adaptive icon, web maskable icons) need a full-bleed opaque square instead, so
the area outside the artwork is filled by diffusing the artwork's own edge
colours outwards, which continues its background gradient without a seam.
"""

import json
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MASTER = os.path.join(ROOT, "assets", "icon", "app_icon.png")

# Android density buckets: legacy icon size, adaptive layer size (108dp).
ANDROID_DENSITIES = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}
# An adaptive icon is masked to 72dp of its 108dp canvas and only the middle
# 66dp is guaranteed to be visible; the artwork reaches 85% of the master's
# width, so 0.72 keeps all of it inside that safe zone.
ADAPTIVE_CONTENT = 0.72
# A maskable web icon must keep its content inside the middle 80%.
MASKABLE_CONTENT = 0.85


def load_master():
    if not os.path.exists(MASTER):
        sys.exit(f"missing master icon: {MASTER}")
    im = Image.open(MASTER).convert("RGBA")
    if im.width != im.height:
        sys.exit(f"master icon must be square, got {im.size}")
    return im


def diffuse_fill(rgb, known, size):
    """Fill everything outside `known` by diffusing the known colours outwards.

    Solved coarse-to-fine: each level blurs the image and puts the known pixels
    back, which spreads colour into the unknown area without any hard edge. The
    unknown area starts out at the average known colour rather than black, so
    that downscaling never mixes black into the icon's own edge.
    """
    k = known[..., None]
    mean = (rgb * k).sum(axis=(0, 1)) / max(known.sum(), 1e-6)
    src = Image.fromarray(np.clip(rgb * k + mean * (1 - k), 0, 255).astype(np.uint8), "RGB")
    mask = Image.fromarray((known * 255).astype(np.uint8), "L")

    out = None
    for res in (32, 64, 128, 256, 512, 1024):
        res = min(res, size)
        level = np.asarray(src.resize((res, res), Image.LANCZOS)).astype(np.float32)
        a = np.asarray(mask.resize((res, res), Image.LANCZOS)).astype(np.float32) / 255.0
        a = np.clip(a, 0.0, 1.0)[..., None]
        guess = (
            level
            if out is None
            else np.asarray(out.resize((res, res), Image.LANCZOS)).astype(np.float32)
        )
        for _ in range(30):
            blurred = Image.fromarray(np.clip(guess, 0, 255).astype(np.uint8), "RGB").filter(
                ImageFilter.GaussianBlur(2)
            )
            guess = np.asarray(blurred).astype(np.float32) * (1 - a) + level * a
        out = Image.fromarray(np.clip(guess, 0, 255).astype(np.uint8), "RGB")
        if res == size:
            break

    filled = np.asarray(out.resize((size, size), Image.LANCZOS)).astype(np.float32)
    return Image.fromarray(
        np.clip(filled * (1 - k) + rgb * k, 0, 255).astype(np.uint8), "RGB"
    )


def fill_corners(master):
    """The master with its transparent corners filled: an opaque, full-bleed square."""
    a = np.asarray(master).astype(np.float32)
    return diffuse_fill(a[..., :3], a[..., 3] / 255.0, master.width)


def pad(squared, size, content_ratio):
    """Shrink `squared` to `content_ratio` of `size` and grow its background out
    to the full canvas, so the artwork clears the platform's mask."""
    inner = round(size * content_ratio)
    small = squared.resize((inner, inner), Image.LANCZOS)
    canvas = np.zeros((size, size, 3), np.float32)
    known = np.zeros((size, size), np.float32)
    off = (size - inner) // 2
    canvas[off:off + inner, off:off + inner] = np.asarray(small).astype(np.float32)
    known[off:off + inner, off:off + inner] = 1.0
    return diffuse_fill(canvas, known, size)


def save(img, path, size, mode="RGBA"):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS) if img.size != (size, size) else img
    out.convert(mode).save(path, optimize=True)
    print(f"  {os.path.relpath(path, ROOT)} ({size}x{size})")


def android(rounded, squared):
    print("android")
    res = os.path.join(ROOT, "android", "app", "src", "main", "res")
    layers = {}
    for density, (legacy, layer) in ANDROID_DENSITIES.items():
        # pre-Oreo launchers draw the icon unmasked, so keep the rounded corners
        save(rounded, os.path.join(res, f"mipmap-{density}", "ic_launcher.png"), legacy)
        # Oreo+ masks the adaptive layers, so they are full-bleed and opaque
        layers[density] = pad(squared, layer, ADAPTIVE_CONTENT)
        save(
            layers[density],
            os.path.join(res, f"mipmap-{density}", "ic_launcher_foreground.png"),
            layer,
        )

    # the foreground covers the canvas; this only shows if a launcher parallaxes it
    edge = np.asarray(layers["xxxhdpi"])[0, 0]
    colour = "#{:02X}{:02X}{:02X}".format(*edge)
    with open(os.path.join(res, "values", "colors.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            f'    <color name="ic_launcher_background">{colour}</color>\n'
            "</resources>\n"
        )
    print(f"  res/values/colors.xml (background {colour})")

    adaptive = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        "</adaptive-icon>\n"
    )
    path = os.path.join(res, "mipmap-anydpi-v26", "ic_launcher.xml")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(adaptive)
    print("  res/mipmap-anydpi-v26/ic_launcher.xml")


def ios(squared):
    print("ios")
    appicon = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    with open(os.path.join(appicon, "Contents.json")) as f:
        images = json.load(f)["images"]
    # iOS rejects alpha and rounds the corners itself, so every size is opaque RGB
    for spec in images:
        size = round(float(spec["size"].split("x")[0]) * int(spec["scale"].rstrip("x")))
        save(squared, os.path.join(appicon, spec["filename"]), size, mode="RGB")


def web(rounded, squared):
    print("web")
    web_dir = os.path.join(ROOT, "web")
    for size in (192, 512):
        save(rounded, os.path.join(web_dir, "icons", f"Icon-{size}.png"), size)
        save(
            pad(squared, size, MASKABLE_CONTENT),
            os.path.join(web_dir, "icons", f"Icon-maskable-{size}.png"),
            size,
        )
    # iOS fills a transparent home-screen icon with black, so this one is opaque
    save(squared, os.path.join(web_dir, "icons", "Icon-apple-touch-180.png"), 180, mode="RGB")
    save(rounded, os.path.join(web_dir, "favicon.png"), 32)


def main():
    master = load_master()
    squared = fill_corners(master)
    android(master, squared)
    ios(squared)
    web(master, squared)


if __name__ == "__main__":
    main()
