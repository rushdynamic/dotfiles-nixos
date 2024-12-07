#!/usr/bin/env bash

handle() {
  case $1 in
    monitoradded*) 
        hyprctl dispatch dpms off eDP-1
        hyprctl notify -1 10000 "rgb(ff1ea3)" "Added monitor!"
        ;;
    monitorremoved*) 
        hyprctl dispatch dpms on eDP-1
        hyprctl notify -1 10000 "rgb(ff1ea3)" "Removed monitor!"
        ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done