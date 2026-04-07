{
  description = "Christian's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude = {
      url = "github:christian-oudard/nix-claude";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    persist = {
      url = "github:christian-oudard/persist";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    agent-capabilities = {
      url = "git+ssh://git@github.com/christian-oudard/agent-capabilities";
      flake = false;
    };
    whisper-dictation-src = {
      url = "github:christian-oudard/whisper_dictation";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      claude-code,
      disko,
      nix-claude,
      persist,
      claude-plugins-official,
      agent-capabilities,
      whisper-dictation-src,
      ...
    }:
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
            faster-whisper
            torch
            sounddevice
            numpy
          ];
        };
      };
      commonModules = [
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            overlay-claude-code
            overlay-whisper-dictation
          ];
        }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.useUserPackages = true;
          home-manager.users.christian = {
            # Disable HM's built-in claude-code module — its `plugins` option
            # conflicts with nix-claude's (home-manager#8934).
            # Re-enable once the types are reconciled upstream.
            disabledModules = [ "programs/claude-code.nix" ];
            imports = [
              nix-claude.homeModules.default
              (import ./home.nix {
                username = "christian";
                inherit persist claude-plugins-official agent-capabilities;
              })
            ];
          };
        }
      ];
    in
    {
      nixosConfigurations.dedekind = nixpkgs.lib.nixosSystem {
        modules = [
          { nixpkgs.hostPlatform = system; }
          disko.nixosModules.disko
          ./hosts/dedekind/configuration.nix
        ]
        ++ commonModules;
      };

      nixosConfigurations.cantor = nixpkgs.lib.nixosSystem {
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./hosts/cantor/configuration.nix
        ]
        ++ commonModules;
      };
    };
}
