{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d";

  # System settings
  networking.hostName = "nixos";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
  };

  # PipeWire (better than PulseAudio)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Desktop Environment & Display Manager
  programs.hyprland.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Auto-login idle prevention
  services.logind = {
    extraConfig = ''
      IdleAction=ignore
      IdleActionSec=0
      HandleLidSwitch=ignore
      HandleLidSwitchDocked=ignore
    '';
  };

  # User account
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    emacs
    brave
    kitty
    waybar
    xorg.xset
  ];


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
