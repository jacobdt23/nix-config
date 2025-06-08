{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";

  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  home.packages = with pkgs; [
    htop
    tree
    gh
    vscode
  ];

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      github.copilot
    ];
  };
}
