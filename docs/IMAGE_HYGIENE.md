# Image hygiene (duplicate + unused images)

Two advisory tools that keep app size down by reporting redundant image assets.
They only **list candidates for human review** — they never delete anything.

| Tool | What it finds | Engine |
| --- | --- | --- |
| `scripts/find_duplicate_images.py` | Pixel-identical images stored more than once | Custom (Pillow) |
| `scripts/find_unused_images.py` | Asset-catalog images referenced nowhere | FengNiao + wrapper |

## Run locally

```bash
# duplicates (needs Pillow: pip install Pillow)
python scripts/find_duplicate_images.py RecipeBox --root .

# unused (needs FengNiao: mint install onevcat/FengNiao)
FENGNIAO="$HOME/.mint/bin/fengniao" python scripts/find_unused_images.py RecipeBox

# self-test: builds fixtures for every case and asserts the reports
FENGNIAO="$HOME/.mint/bin/fengniao" python scripts/test_image_hygiene.py
```

## CI

`.github/workflows/hygiene.yml` runs weekly (Mon) + on demand (`workflow_dispatch`):

- **self-test** (macOS) — gate on every push; fails on any tool regression.
- **scan-duplicates** (Ubuntu, cheap — no Xcode) — uploads `duplicates.md`.
- **scan-unused** (macOS — FengNiao is a Swift tool) — uploads `unused.md`.

Scans are advisory (never fail the build); review the artifacts and clean up in
batches. FengNiao is pinned and its Mint build is cached.

## How duplicate detection works (precision-first)

- Hashes the **decoded, normalised RGBA pixels** (+ size), not file bytes. This
  catches re-encoded copies and RGB-vs-opaque-RGBA copies a byte hash misses,
  and **never** flags merely-similar images the way an MSE/threshold tool does.
- **Asset-catalog aware**: slots inside one set (e.g. `@1x/@2x/@3x` of an
  `.imageset`, or the sizes of an `.appiconset`) are never flagged against each
  other; identical images across *different* sets are.
- Formats Pillow can't decode (`.pdf`) fall back to a byte hash, so only
  byte-identical copies are reported for them.

### What duplicate detection does NOT catch (by design)

Precision-first: it only flags pixel-identical copies, so it deliberately
misses ambiguous cases that would otherwise need human triage anyway:

- **Near-duplicates** — resized, recoloured, cropped, or lossily re-encoded
  (e.g. re-saved JPEG) copies of the same artwork. The biggest intentional
  gap; catching these needs a similarity threshold that produces false alarms.
- **Intra-imageset duplicates** — identical slots *inside one* `.imageset`
  (e.g. the same image used for both light and dark appearance). App thinning
  already slices idiom/scale/gamut per device, so only the appearance/size-class
  axes would be genuine waste, and that small/rare case isn't worth the
  Contents.json parsing required to detect it precisely.
- **Cross-format copies** — the same image stored as both PNG and JPG (lossy
  decode differs), or PNG vs PDF.
- **PDF/GIF** — compared by raw bytes only; visually-identical files with
  different bytes are not matched.
- **Out of scan scope** — assets in other targets / SPM resource bundles, and
  network images (`RemoteImage`/`AsyncImage`), are not considered.

This complements `scripts/check_image_size.sh` (a pre-commit guard against
oversized images) — that checks file *size*, this checks *redundancy*.

## How unused detection works (and its limits)

FengNiao extracts asset names and greps source for usages. The wrapper adds:

- **Allowlist** (`scripts/image-allowlist.txt`): regex names that are built at
  runtime (e.g. `Image("icon_\(type)")`) and therefore can't be resolved
  statically. Add your project's dynamic prefixes here, or they'll be reported.
- **Extra-glob usage scan** (default `*.json`): FengNiao ignores file types it
  doesn't know; the wrapper greps these itself so config-referenced images
  aren't falsely reported.

> ⚠️ Static analysis **cannot** be 100% accurate for unused images — names built
> from server data or string concatenation are undecidable. Always review before
> deleting, and extend the allowlist for known dynamic names.

## Adopting in another project / the template

- Point `hygiene.yml`'s `push.branches` at your default branch (and note GitHub
  only fires `schedule` on the default branch). In the iOSAppTemplate starter,
  ship it as `hygiene.yml.example` per the repo convention.
- `image-allowlist.txt` ships empty (examples only) — each project adds its own
  dynamic-name patterns; until then `scan-unused` has no allowlist protection.
- Adjust the scanned project path (`RecipeBox`) and `--extra-glob` as needed.
