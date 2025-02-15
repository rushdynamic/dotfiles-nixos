#!/usr/bin/env bash
picom --config ~/.config/picom/picom.conf &
feh --bg-fill --randomize --no-fehbg /home/rushdynamic/Pictures/Wallpapers/ &
polybar -c ~/.config/polybar/config &
autotiling -w 2 &
pactl load-module module-null-sink sink_name=virtmic sink_properties=device.description=Virtual_Microphone_Sink rate=48000 channels=2