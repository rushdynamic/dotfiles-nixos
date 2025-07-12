#!/usr/bin/env bash

volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n1)

device=$(pactl list sinks | awk -v sink="$(pactl get-default-sink)" '
  $0 ~ "Name: "sink { found=1 }
  found && $0 ~ /Description:/ {
    sub(/^\s*Description: /, "", $0)
    print $0
    exit
  }
')

echo "$device"