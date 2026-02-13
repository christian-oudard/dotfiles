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
    whisper-dictation-src = {
      url = "github:christian-oudard/whisper_dictation";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, claude-code, whisper-dictation-src, ... }:
    let
      system = "x86_64-linux";
      overlay-claude-code = final: prev: {
        claude-code = claude-code.packages.${system}.default;
      };
      overlay-whisper-dictation = final: prev: {
        whisper-dictation = prev.python3Packages.buildPythonApplication {
          pname = "whisper-dictation";
          version = "0.1.0";
          src = whisper-dictation-src;
          pyproject = true;
          build-system = [ prev.python3Packages.setuptools ];
          dependencies = with prev.python3Packages; [
            faster-whisper torch sounddevice numpy
          ];
        };
      };
      commonModules = [
        home-manager.nixosModules.home-manager
        { nixpkgs.overlays = [ overlay-claude-code overlay-whisper-dictation ]; }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.christian = import ./home.nix { username = "christian"; };
        }
      ];
    in {
      nixosConfigurations.dedekind = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/dedekind/configuration.nix disko.nixosModules.disko ] ++ commonModules;
      };

      nixosConfigurations.cantor = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/cantor/configuration.nix ] ++ commonModules;
      };
    };
}
