{
  description = "Christian's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, claude-code, ... }:
    let
      system = "x86_64-linux";
      overlay-claude-code = final: prev: {
        claude-code = claude-code.packages.${system}.default;
      };
    in {
      nixosConfigurations.dedekind = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/dedekind/configuration.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          { nixpkgs.overlays = [ overlay-claude-code ]; }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.christian = import ./home.nix { username = "christian"; };
            home-manager.users.agent = import ./agent-home.nix;
          }
        ];
      };
    };
}
