#!/usr/bin/env bash
# Create Altair's unlock art: a mid-century expedition mainframe operator console.
set -euo pipefail
cd "$(dirname "$0")/.."
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

BG='#171923'
BEZEL='#c8b99e'
BEZEL_LIGHT='#e0d4c0'
BEZEL_DARK='#716b68'
PANEL='#343946'
SCREEN='#111923'
SCREEN_EDGE='#9ca7ad'
SILVER='#c5c5c2'
TEXT='#d9d0c3'
PINK='#e87993'
GREEN='#83b78c'
BLUE='#8eafc0'
AMBER='#d8bd8d'
DIM='#85838b'

FB='JetBrains-Mono-ExtraBold'
FM='JetBrains-Mono-Bold'
FR='JetBrains-Mono-Regular'

W=1240
H=320
canvas="$WORK/console.png"

# Warm silver/beige machine housing with a restrained bevel and rose status LED.
magick -size ${W}x${H} xc:none \
  -draw "fill rgba(0,0,0,0.42) roundrectangle 5,8 1234,315 18,18" \
  -draw "fill $BEZEL roundrectangle 0,0 1230,307 18,18" \
  -draw "fill none stroke $BEZEL_LIGHT stroke-width 3 roundrectangle 3,3 1227,304 15,15" \
  -draw "fill none stroke $BEZEL_DARK stroke-width 2 roundrectangle 8,8 1222,299 12,12" \
  "$canvas"

# Manufacturer badge and control labels.
magick "$canvas" \
  -font "$FB" -pointsize 23 -fill "$PANEL" -annotate +28+38 'COMPUTRON' \
  -font "$FM" -pointsize 15 -fill "$BEZEL_DARK" -annotate +29+60 'DYNAMICS  /  ALTAIR-IV SURVEY' \
  -font "$FR" -pointsize 12 -fill "$BEZEL_DARK" -annotate +900+34 'OPERATOR TERMINAL' \
  -fill "$PINK" -draw "circle 1184,29 1192,29" \
  -font "$FM" -pointsize 11 -fill "$BEZEL_DARK" -annotate +1152+54 'READY' \
  "$canvas"

# Convex CRT glass; dark screen, subtle bezel, phosphor copy and oscilloscope trace.
magick "$canvas" \
  -draw "fill $PANEL roundrectangle 24,78 827,272 12,12" \
  -draw "fill $SCREEN roundrectangle 35,89 816,260 9,9" \
  -draw "fill none stroke $SCREEN_EDGE stroke-width 2 roundrectangle 35,89 816,260 9,9" \
  -font "$FM" -pointsize 12 -fill "$BLUE" -annotate +58+119 'SYSTEM STATUS     COMPUTRON OS/2000' \
  -font "$FM" -pointsize 21 -fill "$GREEN" -annotate +58+158 'SYSTEM READY' \
  -font "$FR" -pointsize 15 -fill "$TEXT" -annotate +58+190 'OPERATOR IDENTIFICATION REQUIRED' \
  -font "$FR" -pointsize 14 -fill "$GREEN" -annotate +58+226 'AWAITING INPUT' \
  -fill "$PINK" -draw "rectangle 199,212 208,229" \
  "$canvas"

# Fine CRT scanlines, kept subtle enough not to interfere with the text.
python3 - "$WORK/scanlines.mvg" <<'PY'
import sys
with open(sys.argv[1], 'w') as f:
    for y in range(95, 258, 4):
        f.write(f"fill 'rgba(190,202,213,0.055)' rectangle 40,{y} 810,{y+1}\n")
PY
magick "$canvas" -draw "$(cat "$WORK/scanlines.mvg")" "$canvas"

# Analog instrument cluster on the right: two gauges, ticks, and a memory trace.
magick "$canvas" \
  -font "$FM" -pointsize 11 -fill "$BEZEL_DARK" -annotate +865+83 'LINE / SYNC' \
  -draw "fill $PANEL roundrectangle 850,93 1018,231 8,8" \
  -draw "fill $SCREEN roundrectangle 858,101 1010,221 5,5" \
  -draw "fill none stroke $SILVER stroke-width 2 arc 878,113 990,205 200,340" \
  -draw "fill none stroke ${BLUE} stroke-width 2 arc 889,124 979,194 205,335" \
  -draw "fill none stroke $PINK stroke-width 3 line 934,170 975,139" \
  -draw "fill $BEZEL_LIGHT circle 934,170 939,170" \
  -font "$FR" -pointsize 10 -fill "$SILVER" -annotate +871+214 'LOW' \
  -annotate +972+214 'NORM' \
  -font "$FM" -pointsize 11 -fill "$BEZEL_DARK" -annotate +1032+83 'MEMORY' \
  -draw "fill $PANEL roundrectangle 1028,93 1204,231 8,8" \
  -draw "fill $SCREEN roundrectangle 1036,101 1196,221 5,5" \
  -draw "fill none stroke ${GREEN} stroke-width 2 path 'M 1048,180 L 1068,180 L 1080,152 L 1092,198 L 1104,164 L 1116,180 L 1130,180 L 1142,139 L 1153,190 L 1165,180 L 1184,180'" \
  -font "$FR" -pointsize 10 -fill "$BLUE" -annotate +1081+211 '64K / READY' \
  "$canvas"

# Punch-card / function keys along the lower deck.
magick "$canvas" \
  -font "$FM" -pointsize 10 -fill "$BEZEL_DARK" -annotate +28+291 'FUNCTION' \
  -draw "fill $BEZEL_DARK roundrectangle 112,276 218,299 3,3" \
  -draw "fill $BEZEL_DARK roundrectangle 227,276 333,299 3,3" \
  -draw "fill $BEZEL_DARK roundrectangle 342,276 448,299 3,3" \
  -font "$FM" -pointsize 10 -fill "$BEZEL_LIGHT" -annotate +137+292 'CLEAR' \
  -annotate +250+292 'ENTER' \
  -annotate +365+292 'RETURN' \
  -font "$FR" -pointsize 11 -fill "$BEZEL_DARK" -annotate +520+292 'COMPUTRON DYNAMICS  •  ALTAIR-IV EXPEDITION' \
  "$canvas"

magick "$canvas" -strip -depth 8 unlock.png

# Preview mirrors GDM: console centered near the bottom with a 48px margin.
magick -size 1920x1080 xc:"$BG" \
  unlock.png -gravity South -geometry +0+48 -composite \
  -strip -depth 8 preview-unlock.png

echo "unlock.png         $(identify -format '%wx%h' unlock.png)"
echo "preview-unlock.png $(identify -format '%wx%h' preview-unlock.png)"
