#!/bin/bash
# beautify.sh - Add Screen Studio-style background to a screenshot
# Usage: beautify.sh <input> <output> [gradient] [padding] [corner_radius] [shadow_strength]
#
# Examples:
#   beautify.sh screenshot.png beautiful.png
#   beautify.sh screenshot.png beautiful.png "#4158D0-#C850C0-#FFCC70"
#   beautify.sh screenshot.png beautiful.png "#667eea-#764ba2" 300 40 80
#
# Gradient presets:
#   purple:  "#667eea-#764ba2"
#   sunset:  "#4158D0-#C850C0-#FFCC70"
#   ocean:   "#0093E9-#80D0C7"
#   dark:    "#0f0c29-#302b63-#24243e"
#   mint:    "#00b09b-#96c93d"

set -euo pipefail

INPUT="${1:?Usage: beautify.sh <input> <output> [gradient] [padding] [corner_radius] [shadow_strength]}"
OUTPUT="${2:?Missing output path}"
GRADIENT="${3:-#4158D0-#C850C0-#FFCC70}"
PAD="${4:-300}"
RADIUS="${5:-40}"
SHADOW="${6:-80}"

# Parse gradient colors
IFS='-' read -ra COLORS <<< "$GRADIENT"

# Get input dimensions
W=$(identify -format '%w' "$INPUT")
H=$(identify -format '%h' "$INPUT")

# Canvas dimensions with padding
CW=$((W + PAD * 2))
CH=$((H + PAD * 2))

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Step 1: Create gradient background
if [ ${#COLORS[@]} -eq 2 ]; then
  magick -size "${CW}x${CH}" gradient:"${COLORS[0]}"-"${COLORS[1]}" "$TMPDIR/bg.png"
elif [ ${#COLORS[@]} -ge 3 ]; then
  # Multi-color gradient via horizontal append + resize
  COLOR_ARGS=""
  for c in "${COLORS[@]}"; do
    COLOR_ARGS="$COLOR_ARGS xc:$c"
  done
  magick \( $COLOR_ARGS +append \) \
    -filter Gaussian -resize "${CW}x${CH}!" -interpolate catrom \
    "$TMPDIR/bg.png"
else
  magick -size "${CW}x${CH}" "xc:${COLORS[0]}" "$TMPDIR/bg.png"
fi

# Step 2: Round corners on the screenshot
magick "$INPUT" \
  \( +clone -alpha extract \
     -draw "fill black polygon 0,0 0,$RADIUS $RADIUS,0 fill white circle $RADIUS,$RADIUS $RADIUS,0" \
     \( +clone -flip \) -compose Multiply -composite \
     \( +clone -flop \) -compose Multiply -composite \
  \) -alpha off -compose CopyOpacity -composite \
  "$TMPDIR/rounded.png"

# Step 3: Add drop shadow
magick "$TMPDIR/rounded.png" \
  \( +clone -background black -shadow "${SHADOW}x30+0+15" \) \
  +swap -background none -layers merge +repage \
  "$TMPDIR/shadowed.png"

# Step 4: Composite onto gradient background
magick "$TMPDIR/bg.png" "$TMPDIR/shadowed.png" \
  -gravity center -composite \
  "$OUTPUT"

echo "✅ Beautified screenshot saved to $OUTPUT (${CW}x${CH})"
