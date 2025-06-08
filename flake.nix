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

      # Import pkgs with allowUnfree = true for packages
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      # Use nixpkgs.lib.nixosSystem directly here, not pkgs.lib.nixosSystem
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            nixpkgs.config.allowUnfree = true;
          }
          ./configuration.nix
          ./hardware-configuration.nix
          home-manager.nixosModules.home-manager
        ];

        specialArgs = {
          inherit home-manager;
        };
      };

      # For home manager, use the pkgs you imported above
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          ./home.nix
        ];
      };
    };
}
