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
    codex-cli = {
      url = "github:sadjow/codex-cli-nix";
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
    persist = {
      url = "github:christian-oudard/persist";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    diktat = {
      url = "github:christian-oudard/diktat";
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
      codex-cli,
      coding-cave,
      claude-plugins-official,
      persist,
      diktat,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "christian";
      homeDir = "/home/${username}";
      specialArgs = { inherit username homeDir; };
      overlay = final: prev: {
        claude-code = claude-code.packages.${system}.default;
        codex-cli = codex-cli.packages.${system}.default;
      };
      homeCore = import ./home/core.nix {
        inherit
          username
          homeDir
          persist
          claude-plugins-official
          ;
      };
      homeDesktop = import ./home/desktop.nix { inherit diktat; };
      commonModules = [
        home-manager.nixosModules.home-manager
        coding-cave.nixosModules.codingCave
        { nixpkgs.overlays = [ overlay ]; }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            imports = [
              homeCore
              homeDesktop
            ];
            # When these profiles were first activated. core.nix leaves it
            # unset on purpose; each importer states its own.
            home.stateVersion = "24.11";
          };
        }
      ];
    in
    {
      # The headless subset, for hosts outside this repository: the zeal cloud
      # workstation imports all three. Nothing reachable from these may
      # reference the private coding-cave input, or a consumer holding no
      # GitHub credential cannot evaluate. coding-cave and the desktop belong
      # in laptop.nix and the wiring above, which stay unexported.
      nixosModules.common = ./common.nix;
      homeModules = {
        core = homeCore;
        desktop = homeDesktop;
      };
      overlays.default = overlay;

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
