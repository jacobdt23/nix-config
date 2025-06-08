{ config, pkgs, ... }:

{
  home-manager.users.nixos = {
    home.username = "nixos";
    home.homeDirectory = "/home/nixos";
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      htop
      tree
      gh
      vscode
    ];

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        github.copilot
      ];
    };
  };
}
