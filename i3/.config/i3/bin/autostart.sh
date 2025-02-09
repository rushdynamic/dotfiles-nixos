#!/usr/bin/env bash
picom --config ~/.config/picom/picom.conf &
feh --bg-fill /home/rushdynamic/Pictures/Wallpapers/1356532.png &
polybar -c ~/.config/polybar/config &
autotiling -w 2 &
pactl load-module module-null-sink sink_name=virtmic sink_properties=device.description=Virtual_Microphone_Sink rate=48000 channels=2