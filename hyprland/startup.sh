#!/usr/bin/env bash

# Network Manager
nm-applet --indicator &

# Bar
waybar -c ~/.config/waybar/config &

# Focus on monitor's workspace
# hyprctl dispatch workspace 1 