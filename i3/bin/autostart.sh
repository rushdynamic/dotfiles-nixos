#!/usr/bin/env bash

# Accepts the full path to wallpaper as the optional first arg.
# If not provided, picks a random wallpaper from the dir
wallpaper_path="${1:-$(find /home/rushdynamic/Pictures/Wallpapers/ -type f | shuf -n 1)}"

# use Pywal to generate color schemes based on wallpaper
wal -i $wallpaper_path # -f base16-ashes --- set predefined themes using the -f param2

source /home/rushdynamic/Scripts/dotfiles-nixos/i3/bin/themer.sh /home/rushdynamic/.cache/wal/colors-mako # generate global color variables

# generate i3 borders using global color variables
FLAG_FILE="/tmp/i3_reloaded_once"
if [ ! -f "$FLAG_FILE" ]; then
  sed "s|\$border_color|$border_color|g" ~/.config/i3/config.template > ~/.config/i3/config
  touch "$FLAG_FILE"
  i3-msg reload
fi

# if running from i3 (with no wallpaper arg), load all pkgs
if [ -z "$1" ]; then
  picom --config ~/.config/picom/picom.conf &
  # xrandr --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-0 --primary --mode 2560x1440 --pos 1920x0 --rotate normal &
  # Handle multi-monitor setup
  if xrandr | grep -q "^HDMI-0 connected"; then
    # External monitor connected
    xrandr \
        --output eDP-1-1 --mode 1920x1080 --pos 0x0 --rotate normal \
        --output HDMI-0 --primary --mode 2560x1440 --pos 1920x0 --rotate normal
    polybar --reload laptop -c ~/.config/polybar/config &
	else
    # Laptop only
    xrandr \
        --output eDP-1-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
        --output HDMI-0 --off
	fi
  # export POLYBAR_BG="#000000"
  polybar --reload external -c ~/.config/polybar/config &
  autotiling -w 1 2 3 4 &
  pactl load-module module-null-sink sink_name=virtmic sink_properties=device.description=Virtual_Microphone_Sink rate=48000 channels=2
fi

feh --bg-fill --no-fehbg $wallpaper_path &

if ! pgrep -f "bin/redshift" > /dev/null; then
	nohup redshift > /var/log/redshift-output.log 2>&1 &
fi
nohup caffeine > /var/log/caffeine-output.log 2>&1 &
nohup stretchly > /var/log/stretchly-output.log 2>&1 &
nohup flameshot > /var/log/flameshot-output.log 2>&1 &