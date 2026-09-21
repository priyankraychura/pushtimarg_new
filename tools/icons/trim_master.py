#!/usr/bin/env python3
"""Turn an exported icon render into the master at assets/icon/app_icon.png.

Usage: python3 tools/icons/trim_master.py <render.png>

The render is the rounded-square icon sitting on a black background. This crops
it to the artwork, drops the dark antialiased rim at its border and restores the
rounded corners as transparency, so the master is a clean square RGBA image.
"""

import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "icon", "app_icon.png")
MASTER_SIZE = 1024
SOLID = 100  # luma above the antialiased rim, below any artwork element
ERODE = 3  # pixels of rim to discard


def spans(solid, axis):
    """First and last solid index along `axis` for every line of the image."""
    lines = solid if axis == 0 else solid.T
    out = []
    for line in lines:
        hit = np.nonzero(line)[0]
        out.append(None if hit.size == 0 else (int(hit[0]) + ERODE, int(hit[-1]) - ERODE))
    return [s if s and s[0] <= s[1] else None for s in out]


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip())
    src = Image.open(sys.argv[1]).convert("RGB")
    a = np.asarray(src).astype(np.float32)
    luma = a @ np.array([0.299, 0.587, 0.114], dtype=np.float32)
    solid = luma > SOLID

    ys, xs = np.nonzero(solid)
    a = a[ys.min(): ys.max() + 1, xs.min(): xs.max() + 1]
    solid = solid[ys.min(): ys.max() + 1, xs.min(): xs.max() + 1]
    h, w = solid.shape
    print(f"cropped to {w}x{h}")

    # The icon is a convex rounded square, so intersecting the per-row and
    # per-column solid spans reproduces its silhouette, squircle corners and all.
    rows, cols = spans(solid, 0), spans(solid, 1)
    mask = np.zeros((h, w), dtype=np.float32)
    grid_x = np.arange(w)
    for y, row in enumerate(rows):
        if row is None:
            continue
        mask[y] = (grid_x >= row[0]) & (grid_x <= row[1])
    grid_y = np.arange(h)
    for x, col in enumerate(cols):
        if col is None:
            mask[:, x] = 0
            continue
        mask[:, x] *= (grid_y >= col[0]) & (grid_y <= col[1])

    # Crop to the eroded silhouette so that it touches the canvas edges.
    ys, xs = np.nonzero(mask > 0)
    a = a[ys.min(): ys.max() + 1, xs.min(): xs.max() + 1]
    mask = mask[ys.min(): ys.max() + 1, xs.min(): xs.max() + 1]
    h, w = mask.shape
    grid_x, grid_y = np.arange(w), np.arange(h)
    print(f"silhouette {w}x{h}")

    # Extend each row's edge colour over the discarded rim so that downscaling
    # cannot pull the dark background back into the icon's edge.
    row_edges = []
    for y in range(h):
        inside = np.nonzero(mask[y])[0]
        row_edges.append(None if inside.size == 0 else (y, int(inside[0]), int(inside[-1])))
    for y in range(h):  # the outermost rows are all rim: borrow the nearest real one
        if row_edges[y] is None:
            row_edges[y] = next(
                (e for e in row_edges[y:] if e is not None),
                None,
            ) or next(e for e in reversed(row_edges[:y]) if e is not None)

    filled = np.empty_like(a)
    for y, (src_y, lo, hi) in enumerate(row_edges):
        filled[y] = a[src_y][np.clip(grid_x, lo, hi)]

    rgb = Image.fromarray(filled.astype(np.uint8), "RGB").resize(
        (MASTER_SIZE, MASTER_SIZE), Image.LANCZOS
    )
    alpha = Image.fromarray((mask * 255).astype(np.uint8), "L").resize(
        (MASTER_SIZE, MASTER_SIZE), Image.LANCZOS
    )
    out = Image.merge("RGBA", (*rgb.split(), alpha))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    out.save(OUT, optimize=True)
    print(f"wrote {os.path.relpath(OUT, ROOT)} ({MASTER_SIZE}x{MASTER_SIZE})")


if __name__ == "__main__":
    main()
