#!/usr/bin/env bash

# from https://github.com/kianblakley/niri-land/tree/main

wall_dir="$HOME/Pictures/Wallpapers"
cache_dir="$HOME/.cache/thumbnails/bgselector"

mkdir -p "$wall_dir"
mkdir -p "$cache_dir"

# Generate thumbnails
find "$wall_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | while read -r imagen; do
	filename="$(basename "$imagen")"
	thumb="$cache_dir/$filename"
	if [ ! -f "$thumb" ]; then
		magick convert -strip "$imagen" -thumbnail x540^ -gravity center -extent 262x540 "$thumb"
	fi
done

# List wallpapers with icons for rofi
wall_selection=$(ls "$wall_dir" | while read -r A; do echo -en "$A\x00icon\x1f$cache_dir/$A\n"; done | rofi -dmenu -config "$HOME/.config/rofi/bgselector.rasi")

# Set wallpaper and update polybar color
if [ -n "$wall_selection" ]; then
    feh --bg-fill --no-fehbg "$wall_dir/$wall_selection" &
	sleep 0.2
#	colorwaybar "$wall_dir/$wall_selection"
	exit 0
else
	exit 1
fi
