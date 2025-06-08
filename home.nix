{ config, pkgs, ... }:

{
  home-manager.users.nixos = {
    home = {
      username = "nixos";
      homeDirectory = "/home/nixos";

      # ✅ This line is mandatory!
      stateVersion = "25.05";
    };

    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      htop
      tree
      gh

    ];
  };
}
