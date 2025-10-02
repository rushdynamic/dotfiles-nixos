#!/usr/bin/env bash
# Usage: showcolor "#RRGGBB" [width] [height]

HEX="$1"
WIDTH="${2:-8}"
HEIGHT="${3:-3}"

if [[ -z "$HEX" ]]; then
  echo "Usage: $0 \"#RRGGBB\" [width] [height]"
  exit 1
fi

# Strip '#' and split into R, G, B
RGB=$(echo "$HEX" | sed 's/#//; s/../0x& /g')
read R G B <<< "$RGB"

# Print block with background color
for ((i=0; i<HEIGHT; i++)); do
  printf "\033[48;2;%d;%d;%dm%*s\033[0m\n" "$R" "$G" "$B" "$WIDTH" ""
done
