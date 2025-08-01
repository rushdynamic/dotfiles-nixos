{ pkgs }:

with pkgs; [
  vim
  vscodium
  vlc
  #  wget
  kitty
  spotify
  brave
  git
  git-credential-manager
  libsecret
  nvitop
  stow
  rofi
  alacritty
  killall
  fzf
  socat
  taskwarrior3
  obsidian
  pavucontrol
  go
  feh
  picom
  nix-search-cli
  xfce.thunar
  aria2
  unzip
  (polybar.override {
    pulseSupport = true;
  })
  obs-studio
  autotiling
  lxappearance
  exercism
  yarn
  nodejs

  bluez
  bluez-tools
  blueberry

  zathura
  pulsemixer
  dunst
  libnotify
  htop
  protonvpn-gui
  insomnia
  tinygo
  neovim
  leiningen
  clojure
  babashka
  ranger
  openvpn
  playerctl
  simplescreenrecorder
  typescript
  stremio
  pfetch
  kdePackages.kdeconnect-kde
  parted
  ntfs3g
  unrar
  networkmanagerapplet
  xdo
  gtk3
  dconf
  gnome-themes-extra
  bitwarden-cli
  llm
  python3Full
  gimp-with-plugins
  chromium
  gpu-screen-recorder-gtk
  unstable.claude-code
  stretchly
  slack
  envsubst
  xclip
  os-prober
  efibootmgr
  gum
  ghostty
]