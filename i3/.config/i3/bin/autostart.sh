#!/usr/bin/env bash
picom --config ~/.config/picom/picom.conf &
random_wall=$(find /home/rushdynamic/Pictures/Wallpapers/ -type f | shuf -n 1)
# use Pywal to generate color schemes based on wallpaper
wal -i $random_wall # -f base16-ashes --- set predefined themes using the -f param2

source /home/rushdynamic/Scripts/dotfiles-nixos/i3/.config/i3/bin/themer.sh /home/rushdynamic/.cache/wal/colors-mako # generate global color variables

# generate i3 borders using global color variables
FLAG_FILE="/tmp/i3_reloaded_once"
if [ ! -f "$FLAG_FILE" ]; then
  sed "s|\$border_color|$border_color|g" ~/.config/i3/config.template > ~/.config/i3/config
  touch "$FLAG_FILE"
  i3-msg reload
fi

xrandr --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-0 --primary --mode 2560x1440 --pos 1920x0 --rotate normal &
polybar --reload laptop -c ~/.config/polybar/config &
# export POLYBAR_BG="#000000"
polybar --reload external -c ~/.config/polybar/config &
feh --bg-fill --no-fehbg $random_wall &
autotiling -w 1 2 3 4 &
pactl load-module module-null-sink sink_name=virtmic sink_properties=device.description=Virtual_Microphone_Sink rate=48000 channels=2