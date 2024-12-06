#!/usr/bin/env bash

push_config() {
    local prog_name="$1"
    local curr_path="/home/rushdynamic/.config/$1"
    local new_path="./$1/.config/"
    mkdir -p "${new_path}"
    mv "${curr_path}" "${new_path}"
    stow -t "/home/rushdynamic/" -S $1 -v
}

if [ -z "$1" ]; then
    echo "Usage: $0 <program-name>"
    echo -e "Example:\n `$0 rofi`\n"
    echo "This would copy `~/.config/rofi` to `./rofi/config/rofi`"
    exit 1
fi

push_config $1