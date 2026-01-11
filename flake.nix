{
  description = "Christian's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.x1carbon = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/x1carbon/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ agenix.homeManagerModules.default ];
            home-manager.extraSpecialArgs = { secretsPath = ./secrets; };
            # christian: packages only (dotfiles via chezmoi)
            home-manager.users.christian = import ./home-packages-only.nix;
            # testuser: full home-manager config (for testing)
            home-manager.users.testuser = import ./home.nix { username = "testuser"; };
          }
        ];
      };

      # Expose agenix CLI for encrypting secrets
      packages.${system}.default = agenix.packages.${system}.default;
    };
}
