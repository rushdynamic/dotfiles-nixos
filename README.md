# NixOS & Hyprland dotfiles

Personal configuration files for my NixOS x Hyprland build. Also includes dots for various misc programs.
Uses `GNU stow` for managing dotfiles.

### Adding a new config

All config files and folders reside in this cloned repository.
`stow` creates and manages the symlinks to these files and folders to their appropriate locations.

Eg: Steps for adding dotfiles for `waybar` that resides in `~/.config/waybar` would be:

- Move `~/.config/waybar` to `./waybar/.config/waybar` (inside this cloned repo)
- Run stow `stow -t ~ -S waybar -v`

Note: need to specify the where the parent directory (in this case `~`) is supposed to be for the contents of our local waybar directory using `-t`.
