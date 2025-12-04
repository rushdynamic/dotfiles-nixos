pactl unload-module module-null-sink
killall polybar
killall picom
pkill -f redshift
rm /tmp/i3_reloaded_once
i3 restart