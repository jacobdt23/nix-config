{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # ✅ Custom pkgs with unfree allowed
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          # ✅ Correct way to pass pre-configured pkgs
          { nixpkgs.pkgs = pkgs; }

          # ✅ Prevent NixOS from trying to apply nixpkgs.config again
          "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"

          ./configuration.nix
          ./hardware-configuration.nix

          # ✅ Enable Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          ./home.nix
        ];

        specialArgs = {
          inherit pkgs home-manager;
        };
      };
    };
}
