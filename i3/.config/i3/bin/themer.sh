#!/usr/bin/env bash

wallpaper=$1

read -ra res <<< "$(/home/rushdynamic/Scripts/dotfiles-nixos/i3/.config/i3/bin/huegenics "$wallpaper")"
export POLYBAR_BG="${res[0]}"
export I3_BG="${res[1]}"
export POLYBAR_ACCENT="${res[1]}"
theme=${res[2]}
if [ "$theme" = "dark" ]; then
    export POLYBAR_FG="#fefefe"
    export POLYBAR_COMP="#121212"
else
    export POLYBAR_FG="#121212"
    export POLYBAR_COMP="#fefefe"
fi
# notify-send "Themer" "FG: $POLYBAR_FG, THEME: ${theme}"
