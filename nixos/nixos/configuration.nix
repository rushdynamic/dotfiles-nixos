# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/nvidia.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.timeout = 5;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    useOSProber = true;
    devices = [ "nodev" ];  # for UEFI
  };

  networking.hostName = "bebop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Default session selection
  services.displayManager.defaultSession = "none+i3";


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  programs.hyprland.enable = false;

  # enabling i3-gaps
  environment.pathsToLink = [ "/libexec" ];
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    extraPackages = with pkgs; [
      dmenu
      i3status
      i3lock
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Mount Windows partitions
  fileSystems."/home/rushdynamic/Mount/Windows/Work" = {
    device = "/dev/sda1";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=022" ];
  };

  fileSystems."/home/rushdynamic/Mount/Windows/Misc" = {
    device = "/dev/sda3";
    fsType = "ntfs-3g";
    options = [ "uid=1000" "gid=100" "umask=022" ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;

  #   # use the example session manager (no others are packaged yet so this is enabled by default,
  #   # no need to redefine it in your config for now)
  #   #media-session.enable = true;
  # };

  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rushdynamic = {
    isNormalUser = true;
    description = "Rush Dynamic";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  environment.sessionVariables = {
	LIBVA_DRIVER_NAME = "nvidia";
	__GLX_VENDOR_LIBRARY_NAME = "nvidia";
	NVD_BACKEND = "direct";
	__NV_PRIME_RENDER_OFFLOAD = "1";
	__NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
	__VK_LAYER_NV_optimus = "NVIDIA_only";
	GBM_BACKEND = "nvidia";
  };

  environment.shellAliases = {
    nconfig = "codium /etc/nixos";
    i3config = "codium ~/.config/i3";
    cod = "codium";
    gs = "git status";
    gfo = "git fetch origin";
    ga = "git add";
    gd = "git diff";
    gl = "clear && git log --oneline";
    dots = "cd /home/rushdynamic/Scripts/dotfiles-nixos";
    fff = "fzf --preview=\"cat {}\" | wl-copy";
    ffo = "code $(fzf --preview=\"cat {}\")";
    ta = "task add";
    tn = "task next";
    tl = "task list";
    ka = "killall";
    pf = "clear && pfetch";
    x = "xclip -selection clipboard";
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = { 
      credential.helper = "libsecret";
    };
  };

   programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable
  programs.ssh = {
    enableAskPassword = true;
    askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.resolved.enable = true;

  nixpkgs.overlays = [
    (self: super: {
      unstable = import <nixos-unstable> { 
        system = self.system;
        config.allowUnfree = true;
      };
    })
  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
environment.systemPackages = import ./modules/user-packages.nix { inherit pkgs; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.virtualbox.host.enable = true;
  # boot.kernelParams = [ "kvm.enable_virt_at_load=0" ]; # for virtualbox


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
