# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # for grub
  boot.loader= {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
     # useOSProber = true;
    };
  };

  networking.hostName = "nixos-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # user account
  users.users.angry = {
    isNormalUser = true;
    description = "angry";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # SYSTEM PACKAGES
  environment.systemPackages = with pkgs; [
    vim
    wget
    pavucontrol
    lynx
    xscreensaver # "xscreensaver-command -lock" runs it, need to turn of screen timeout for it to stay screensaving
    xfce.mousepad
    wireshark
    distrobox
    nix-index # for finding nix packages, nix-index generates database, nix-locate <package> to find what provides
    pciutils # for lspci
    python3
    syncplay
    starship
    alacritty
    p7zip
    btrfs-assistant
    btop
    mullvad-vpn
    opentabletdriver
    gparted
    libsForQt5.filelight
    wineWowPackages.stable
    winetricks
    cifs-utils
    nfs-utils
    ffmpeg
    kate
    imagemagick
    gifski
    clolcat
    cmatrix
    cbonsai
    sl
    neo-cowsay
    neofetch
    fastfetch
    uwufetch
    owofetch
    uwuify
    git
    steam-run
    ruffle
    libsForQt5.konversation
    appimage-run
    #(import <unstable> {}).appimage-run # sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable AND THEN sudo nix-channel --update unstable
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    corefonts
    roboto
  ];

  # for mullvad
  services.mullvad-vpn.enable = true;
  services.resolved.enable = true;  

  # for obs virtualcam
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = '' options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1 '';

  # for virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  # for podman
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # flatpak 
  services.flatpak.enable = true;
#  xdg.portal = {
#    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
#    config.common.default = "gtk";
#    enable = true;
#  }; # run flatpak install org.gtk.Gtk3theme.Breeze for dark theme 

  # unaccepted pr to fix flatpak issue: https://github.com/NixOS/nixpkgs/pull/262462 (reviewed like just now, waiting to be pushed)

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9deb876b-b300-40c9-bb23-5bc7cf20dcdf";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };
  
  fileSystems."/home/angry/Games" = 
    { device = "/dev/disk/by-uuid/dade113d-a2d6-4dba-8376-65c969c9f1ce";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:1" "nofail" "nodiratime" ];
    };

  # remove kdeplasma garbage
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    plasma-browser-integration
    elisa
  ];

  # enable starship for bash
  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    directory.truncation_length = 0;
  };

  # SYSTEM SERVICES
  nix.gc.automatic = true; # nix automatic package garbage collection
  nix.gc.dates = "12:00"; # equivalent to nix-collect-garbage, add -d for old roots
  nix.settings.auto-optimise-store = true; # automatically does nix-store --optimise

  services.fstrim.enable = true; # for ssd trim
  services.printing.enable = true; # cups

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.xserver = { # enable x11
    enable = true;
    xkb.layout = "us"; # keymap
    xkb.variant = "";
  };    

  services.xserver.displayManager.sddm.enable = true; # for kdeplasma
  services.xserver.displayManager.sddm.theme = "breeze-dark";
  services.xserver.desktopManager.plasma5.enable = true; # for kdeplasma 

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true; # for jack applications
    #media-session.enable = true; # use example session manager, no others exist so default already
  };

  # Enable GPU stuff
  # openGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
   hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module instead (not nouveau but the official one)
    open = false;
    # nvidia-settings menu
    nvidiaSettings = true;
    # gpu driver
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # opentabletdriver for drawing tablets
  hardware.opentabletdriver.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
