#!/bin/bash
# blur.sh - Blur a region of an image using ImageMagick
# Usage: blur.sh <input> <output> <x> <y> <width> <height> [blur_strength]
#
# Example:
#   blur.sh screenshot.png blurred.png 0 680 300 1200 40
#
# Multiple regions: chain calls, each reading the previous output.

set -euo pipefail

INPUT="${1:?Usage: blur.sh <input> <output> <x> <y> <width> <height> [blur_strength]}"
OUTPUT="${2:?Missing output path}"
X="${3:?Missing x coordinate}"
Y="${4:?Missing y coordinate}"
W="${5:?Missing width}"
H="${6:?Missing height}"
STRENGTH="${7:-40}"

magick "$INPUT" \
  \( +clone -region "${W}x${H}+${X}+${Y}" -blur "0x${STRENGTH}" \) \
  -compose over -composite \
  "$OUTPUT"

echo "✅ Blurred ${W}x${H} region at (${X},${Y}) → $OUTPUT"
