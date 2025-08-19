#/usr/bin/env sh
unset COLORTERM
TERM=xterm-old
nmcli device wifi rescan
nmtui