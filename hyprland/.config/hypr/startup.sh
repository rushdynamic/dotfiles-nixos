#!/usr/bin/env bash

swww init &

swww img ~/Pictures/Wallpapers/wallhaven-wejjg6.jpg &

# Network Manager
nm-applet --indicator &

# Bluetooth Manager
blueman-applet &

# Bar
waybar -c ~/.config/waybar/config &

# Focus on monitor's workspace
# hyprctl dispatch workspace 1 