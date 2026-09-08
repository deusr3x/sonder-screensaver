#!/bin/bash

# Sonder screensaver for macOS (also works on Linux).
#
# Renders the Sonder logo (sonder-logo.txt) through TTE / ttfx in Sonder
# brand colours, rotating through effects. Press any key (and on macOS,
# move/click the mouse) to exit.
#
# Requires one of:
#   - ttfx  (Rust binary)          -> https://github.com/LukeZHarris/ttfx
#   - tte / terminaltexteffects    -> pipx install terminaltexteffects
#
# Usage:
#   ./sonder-screensaver
#   ./sonder-screensaver <effect>   # force one effect, e.g. pour

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOGO_FILE="${SONDER_LOGO:-$SCRIPT_DIR/sonder-logo.txt}"

# Sonder brand palette
SONDER_BLUE="2f5be9"
SONDER_NAVY="000f2e"
SONDER_GREEN="b2ff57"
SONDER_ORANGE="ff9f6b"
SONDER_SKY="bdeaff"
SONDER_LIME="dcfeb4"

# Detect the TTE binary
if command -v ttfx >/dev/null 2>&1; then
  TTE=ttfx
elif command -v tte >/dev/null 2>&1; then
  TTE=tte
else
  echo "Sonder screensaver: need 'ttfx' or 'tte' installed." >&2
  echo "  ttfx: https://github.com/LukeZHarris/ttfx/releases" >&2
  echo "  tte:  pipx install terminaltexteffects" >&2
  exit 1
fi

# Terminal background to black
printf '\033]11;rgb:00/00/00\007'

sonder_effects=(
  "synthgrid --grid-gradient-stops $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE"
  "pour --final-gradient-stops $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE"
  "waves --wave-gradient-stops $SONDER_BLUE $SONDER_SKY $SONDER_GREEN"
  "smoke --smoke-gradient-stops $SONDER_BLUE $SONDER_NAVY --starting-color $SONDER_BLUE"
  "slice --final-gradient-stops $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE"
  "unstable --unstable-color $SONDER_BLUE --final-gradient-stops $SONDER_NAVY $SONDER_BLUE $SONDER_GREEN"
  "scattered --final-gradient-stops $SONDER_BLUE $SONDER_SKY $SONDER_LIME"
  "sweep --final-gradient-stops $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE"
  "rings --ring-colors $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE --final-gradient-stops $SONDER_BLUE $SONDER_GREEN $SONDER_ORANGE"
  "middleout --starting-color $SONDER_BLUE --final-gradient-stops $SONDER_NAVY $SONDER_BLUE $SONDER_GREEN"
)

run_effect() {
  local effect="$1"
  "$TTE" -i "$LOGO_FILE" \
    --frame-rate 60 --canvas-width 0 --canvas-height 0 --reuse-canvas --anchor-canvas c --anchor-text c \
    --no-eol --no-restore-cursor $effect
}

trap 'exit 0' INT TERM HUP

if [[ $# -ge 1 ]]; then
  name="$1"
  matched=""
  for e in "${sonder_effects[@]}"; do
    if [[ "$e" == "$name"* ]]; then
      matched="$e"
      break
    fi
  done
  run_effect "${matched:-${sonder_effects[0]}}"
  exit 0
fi

while true; do
  idx=$((RANDOM % ${#sonder_effects[@]}))
  run_effect "${sonder_effects[$idx]}" &
  pid=$!
  # Wait for the effect while exiting as soon as a key is pressed.
  while kill -0 "$pid" 2>/dev/null; do
    if read -r -n1 -t 0.1 _ 2>/dev/null; then
      kill "$pid" 2>/dev/null
      exit 0
    fi
  done
  wait "$pid" 2>/dev/null
done
