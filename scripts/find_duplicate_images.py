#!/usr/bin/env python3
"""Find duplicate images in an Xcode project (asset-catalog aware).

Detection strategy (precision-first, no similarity threshold):
- Decode each image and hash its NORMALISED pixels (canonical RGBA buffer +
  size). Two files are "duplicates" only if they are pixel-for-pixel identical
  after normalisation. This catches "same image, different file encoding"
  (re-saved PNG, RGB vs opaque-RGBA) that a raw byte hash would miss, while
  never flagging merely-similar images the way an MSE/threshold tool would.
- Scale variants (@1x/@2x/@3x) inside ONE imageset have different pixel
  dimensions, so they hash differently and are never flagged against each
  other. Identical matches that live entirely within a single imageset are
  skipped defensively as well.
- Formats Pillow cannot decode losslessly (pdf) fall back to a raw byte hash,
  so only byte-identical copies are reported for them.

This tool only REPORTS candidates for human review; it never deletes anything.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
from collections import defaultdict
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.stderr.write("error: Pillow is required (pip install Pillow)\n")
    raise SystemExit(2)

# Extensions we attempt to decode with Pillow for a pixel-level hash.
PIXEL_EXTS = {".png", ".jpg", ".jpeg", ".bmp", ".tiff", ".tif"}
# Extensions we only byte-hash (Pillow can't decode them losslessly here).
BYTE_EXTS = {".pdf", ".gif"}
IMAGE_EXTS = PIXEL_EXTS | BYTE_EXTS


def imageset_of(path: Path) -> Path | None:
    """Return the nearest ancestor *.imageset directory, or None if loose."""
    for parent in path.parents:
        if parent.suffix == ".imageset":
            return parent
    return None


def content_key(path: Path) -> tuple[str, str]:
    """Return (kind, hexdigest) identifying the image content.

    kind is "pixel" or "byte" so we never collide a pixel hash with a byte hash.
    """
    ext = path.suffix.lower()
    if ext in PIXEL_EXTS:
        try:
            with Image.open(path) as img:
                norm = img.convert("RGBA")
                digest = hashlib.sha256()
                digest.update(f"{norm.size[0]}x{norm.size[1]}".encode())
                digest.update(norm.tobytes())
                return ("pixel", digest.hexdigest())
        except Exception:
            pass  # fall through to byte hash for corrupt / undecodable files
    return ("byte", hashlib.sha256(path.read_bytes()).hexdigest())


def label(path: Path, root: Path) -> str:
    """Human label: the imageset name if inside one, else the relative path."""
    iset = imageset_of(path)
    if iset is not None:
        return f"{iset.relative_to(root)} ({path.name})"
    return str(path.relative_to(root))


def find_images(roots: list[Path]) -> list[Path]:
    found: list[Path] = []
    for root in roots:
        if root.is_file():
            if root.suffix.lower() in IMAGE_EXTS:
                found.append(root)
            continue
        for p in sorted(root.rglob("*")):
            if p.is_file() and p.suffix.lower() in IMAGE_EXTS:
                found.append(p)
    return found


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("paths", nargs="*", default=["."],
                    help="Project root(s) or asset catalog(s) to scan.")
    ap.add_argument("--root", default=".",
                    help="Base path used to shorten labels (default: cwd).")
    ap.add_argument("--fail-on-found", action="store_true",
                    help="Exit non-zero when duplicates are found (for gating).")
    args = ap.parse_args()

    roots = [Path(p).resolve() for p in (args.paths or ["."])]
    base = Path(args.root).resolve()

    groups: dict[tuple[str, str], list[Path]] = defaultdict(list)
    for img in find_images(roots):
        groups[content_key(img)].append(img)

    duplicates = []
    for _, files in groups.items():
        if len(files) < 2:
            continue
        # Skip groups confined to a single imageset (expected scale variants).
        isets = {imageset_of(f) for f in files}
        if len(isets) == 1 and None not in isets:
            continue
        duplicates.append(sorted(files))

    print("# Duplicate images report\n")
    if not duplicates:
        print("No duplicate images found. ✅")
        return 0

    total = sum(len(g) - 1 for g in duplicates)
    print(f"Found {len(duplicates)} duplicate group(s), "
          f"~{total} redundant file(s). Review before deleting.\n")
    for i, group in enumerate(sorted(duplicates), 1):
        print(f"## Group {i}")
        for f in group:
            try:
                lbl = label(f, base)
            except ValueError:
                lbl = str(f)
            print(f"- {lbl}")
        print()
    return 1 if args.fail_on_found else 0


if __name__ == "__main__":
    raise SystemExit(main())
