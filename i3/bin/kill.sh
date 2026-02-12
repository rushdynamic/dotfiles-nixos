#!/usr/bin/env bash

pactl unload-module module-null-sink
killall polybar
killall picom