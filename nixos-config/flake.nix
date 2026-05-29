{
  description = "Personal NixOS configuration";

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
    coding-cave = {
      url = "git+ssh://git@github.com/christian-oudard/coding-cave";
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
    persist = {
      url = "github:christian-oudard/persist";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    whisper-dictation = {
      url = "github:christian-oudard/whisper_dictation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      claude-code,
      coding-cave,
      claude-plugins-official,
      agent-capabilities,
      persist,
      whisper-dictation,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "christian";
      homeDir = "/home/${username}";
      specialArgs = { inherit username homeDir; };
      overlay-claude-code = final: prev: {
        claude-code = claude-code.packages.${system}.default;
      };
      overlay-whisper-dictation = final: prev: {
        whisper-dictation = whisper-dictation.packages.${system}.default;
      };
      commonModules = [
        home-manager.nixosModules.home-manager
        coding-cave.nixosModules.codingCave
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
          home-manager.users.${username} = {
            imports = [
              (import ./home.nix {
                inherit username homeDir persist claude-plugins-official agent-capabilities;
              })
            ];
          };
        }
      ];
    in
    {
      nixosConfigurations.dedekind = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          { nixpkgs.hostPlatform = system; }
          disko.nixosModules.disko
          ./hosts/dedekind/configuration.nix
        ]
        ++ commonModules;
      };

      nixosConfigurations.cantor = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./hosts/cantor/configuration.nix
        ]
        ++ commonModules;
      };
    };
}
