{ config, pkgs, ... }:

let
  resolve-fhs = pkgs.buildFHSEnv {
    name = "resolve-fhs";
    targetPkgs = pkgs: with pkgs; [
      glib
      alsa-lib
      libGL
      xorg.libX11
      xorg.libXrandr
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      libuuid
      ffmpeg
    ];
    runScript = "bash ~/.local/bin/resolve.sh";
  };
in {
  home.stateVersion = "25.05";

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = with pkgs; [
    htop
    tree
    gh
    vscode
    resolve-fhs
    flatpak
    gimp
    krita
    inkscape
    obs-studio
    vlc
    glxinfo
    vulkan-tools
    pciutils
    neofetch 
   ];

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
    ];
  };

  home.file.".local/bin/resolve.sh" = {
    text = ''
      #!/usr/bin/env bash
      export LIBGL_ALWAYS_INDIRECT=0
      exec ~/DaVinci_Resolve/Resolve
    '';
    executable = true;
  };

  xdg.enable = true;
}
