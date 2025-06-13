# /home/jacob/nix-config/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";
  nix.gc.options = "--delete-older-than 7d"; # Keep generations for 7 days

# Bootloader configuration (GRUB)
  boot.loader.grub = {
    enable = true;
    # device = "/dev/sda"; # This line is for BIOS installs and must be removed for UEFI
    configurationLimit = 10; # Keep up to 10 entries in the GRUB menu
    # The 'efi = { ... };' block should NO LONGER BE HERE (it's handled by efiSupport)

    # --- ADD THESE TWO LINES ---
    efiSupport = true; # Enable UEFI support for GRUB
    devices = [ "/dev/sda" ]; # Specify the boot disk where GRUB will be installed for UEFI
    # ---------------------------
  };

  # System settings
  networking.hostName = "nixos";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Set your state version for NixOS upgrades
  system.stateVersion = "25.05";
}
