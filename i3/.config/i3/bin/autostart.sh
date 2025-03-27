#!/usr/bin/env bash
picom --config ~/.config/picom/picom.conf &
feh --bg-fill --randomize --no-fehbg /home/rushdynamic/Pictures/Wallpapers/ &
xrandr --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-0 --primary --mode 2560x1440 --pos 1920x0 --rotate normal &
polybar --reload laptop -c ~/.config/polybar/config &
polybar --reload external -c ~/.config/polybar/config &
autotiling -w 1 2 3 4 &
pactl load-module module-null-sink sink_name=virtmic sink_properties=device.description=Virtual_Microphone_Sink rate=48000 channels=2