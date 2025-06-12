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

  # ─── Emacs ──────────────────────────────────────────────────────────────
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  systemd.user.services.emacs = {
    Unit.Description = "Emacs Daemon";
    Service.ExecStart = "${pkgs.emacs}/bin/emacs --fg-daemon";
    Install.WantedBy = [ "default.target" ];
  };

  home.file.".local/bin/resolve.sh" = {
    text = ''
      #!/usr/bin/env bash
      export LIBGL_ALWAYS_INDIRECT=0
      exec ~/DaVinci_Resolve/Resolve
    '';
    executable = true;
  };

  # ─── Bash Customizations ────────────────────────────────────────────────
  programs.bash = {
    enable = true;

    shellAliases = {
      # NixOS Shortcuts
      nrs = "sudo nixos-rebuild switch --flake ~/nix-config#$(hostname)";
      hms = "nix run ~/nix-config#homeConfigurations.$(hostname).activationPackage";
      switchall = "nrs && hms";
      nclean = "sudo nix-collect-garbage -d";
      ngen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      cleanall = "sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system && sudo nix-collect-garbage -d && flatclean && nrs && hms";
      nupdate = "cd ~/nix-config && nix flake update && git add flake.lock && git commit -m 'flake update' && git push && nrs && hms";
      ncfg = "cd ~/nix-config";
      ncheck = "nix flake check ~/nix-config";

      # Emacs
      ec = "GDK_BACKEND=wayland emacsclient -c -a \"\"";

      # File Navigation
      ls = "ls --color=tty";
      l = "ls -alh";
      ll = "ls -l";

      # Git Shortcuts
      gadd = "git add .";
      gcm = "git commit -m";
      gpull = "git pull --rebase";
      gpush = "git push";
      gstatus = "git status -sb";
      glog = "git log --oneline --graph --all";
      gundo = "git reset --soft HEAD~1";

      # Flatpak Cleanup
      flatclean = "flatpak uninstall --unused";

      # Nix Helpers
      nsearch = "nix search nixpkgs";
      nshell = "nix shell nixpkgs#";
      nrun = "nix run nixpkgs#";

      # System Info
      nf = "neofetch";
    };
  };

  # Add important bin dirs to PATH
  home.sessionPath = [
    "$HOME/.emacs.d/bin"
    "$HOME/.nix-profile/bin"
  ];

  xdg.enable = true;
}
