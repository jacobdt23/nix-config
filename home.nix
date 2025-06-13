{ config, pkgs, lib, ... }:

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
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";

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
    ripgrep
  ];

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
    ];
  };

  systemd.user.services.doom-emacs = {
    Unit.Description = "Doom Emacs daemon";
    Unit.WantedBy = [ "default.target" ];

    Service.ExecStart = "${config.home.homeDirectory}/.emacs.d/bin/doom run --daemon";
    Service.Restart = "on-failure";
    Service.Type = "notify";
    Service.NotifyAccess = "all";

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

  # Bash config management
  programs.bash = {
    enable = true;

    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nix-config#$(hostname)";
      hms = "nix run ~/nix-config#homeConfigurations.jacob.activationPackage";
      switchall = "nrs && hms";
      nclean = "sudo nix-collect-garbage -d";
      ngen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      cleanall = "sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system && sudo nix-collect-garbage -d && flatclean && nrs && hms";
      nupdate = "cd ~/nix-config && nix flake update && git add flake.lock && git commit -m 'flake update' && git push && nrs && hms";
      ncfg = "cd ~/nix-config";
      ncheck = "nix flake check ~/nix-config";
      
      ec = "GDK_BACKEND=wayland emacsclient -c -a \"emacs\"";

      ls = "ls --color=tty";
      l = "ls -alh";
      ll = "ls -l";

      gadd = "git add .";
      gcm = "git commit -m";
      gpull = "git pull --rebase";
      gpush = "git push";
      gstatus = "git status -sb";
      glog = "git log --oneline --graph --all";
      gundo = "git reset --soft HEAD~1";

      flatclean = "flatpak uninstall --unused";

      nsearch = "nix search nixpkgs";
      nshell = "nix shell nixpkgs#";
      nrun = "nix run nixpkgs#";

      nf = "neofetch";
    };
  };

  home.sessionPath = [
    "$HOME/.emacs.d/bin"
    "$HOME/.nix-profile/bin"
  ];

  # Manage bashrc and bash_profile directly
  home.file.".bashrc" = {
    text = ''
      # Source Home Manager bash aliases and settings
      if [ -f "${config.home.homeDirectory}/.bash_aliases" ]; then
        . "${config.home.homeDirectory}/.bash_aliases"
      fi

      # Custom bashrc commands
      shopt -s histappend
      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
      HISTFILESIZE=100000
      HISTSIZE=10000
    '';
  };

  home.file.".bash_profile" = {
    text = ''
      # ~/.bash_profile: executed by bash login shells.

      # Source .bashrc if it exists
      if [ -f "${config.home.homeDirectory}/.bashrc" ]; then
        . "${config.home.homeDirectory}/.bashrc"
      fi
    '';
  };

  xdg.enable = true;
}
