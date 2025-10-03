# NixOS & i3-gaps dotfiles

Personal configuration files for my NixOS x i3-gaps build. Also includes dots for various misc programs.
Uses `GNU stow` for managing dotfiles.

### Adding a new config

All config files and folders reside in this cloned repository.
`stow` creates and manages the symlinks to these files and folders to their appropriate locations.

Eg: Steps for adding dotfiles for `waybar` that resides in `~/.config/waybar` would be:
- Move all the contents of `~/.config/waybar` to `./waybar/` (inside this cloned repo)
- Run stow `stow -t ~/.config/waybar -S waybar -v`

---
GTK Font: TeX Gyre Heros Regular
