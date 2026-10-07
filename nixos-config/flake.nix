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
    journal-hours = {
      url = "github:christian-oudard/journal_hours";
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
      claude-plugins-official,
      persist,
      diktat,
      journal-hours,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "christian";
      homeDir = "/home/${username}";
      specialArgs = { inherit username homeDir; };
      overlay = final: prev: {
        claude-code = claude-code.packages.${system}.default;
        codex-cli = codex-cli.packages.${system}.default;
        jh = journal-hours.packages.${system}.default;
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

      # The home-manager wiring, which every host needs identically. What
      # differs is the profiles and the state version, which core.nix leaves
      # unset so each host states its own.
      homeManager =
        { profiles, stateVersion }:
        [
          home-manager.nixosModules.home-manager
          { nixpkgs.overlays = [ overlay ]; }
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              imports = profiles;
              home.stateVersion = stateVersion;
            };
          }
        ];

      laptopModules = homeManager {
        profiles = [
          homeCore
          homeDesktop
        ];
        stateVersion = "24.11";
      };
    in
    {
      nixosConfigurations.dedekind = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          { nixpkgs.hostPlatform = system; }
          disko.nixosModules.disko
          ./hosts/dedekind/configuration.nix
        ]
        ++ laptopModules;
      };

      nixosConfigurations.cantor = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./hosts/cantor/configuration.nix
        ]
        ++ laptopModules;
      };

      nixosConfigurations.zeal = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          { nixpkgs.hostPlatform = system; }
          ./hosts/zeal/configuration.nix
        ]
        ++ homeManager {
          profiles = [ homeCore ];
          stateVersion = "25.05";
        };
      };

      # `nix flake check` evaluates every host above, which is the syntax and
      # eval check. These are what it would still pass over.
      checks.${system} =
        let
          holds = message: sound: if sound then pkgs.emptyFile else throw message;
          cert = self.nixosConfigurations.cantor.config.environment.etc."ssl/cert.pem";
          grub = self.nixosConfigurations.zeal.config.boot.loader.grub;
          mounts = self.nixosConfigurations.zeal.config.fileSystems;
        in
        {
          # security.pki.useCompatibleBundle being dropped silently empties the
          # CA bundle and breaks uv's standalone Python.
          ssl-cert-bundle = holds "ssl/cert.pem no longer points at the NixOS CA bundle: ${cert.source}" (
            cert.enable && builtins.match ".*ca-(bundle|certificates).*" cert.source != null
          );

          # Zeal's disk is partitioned for UEFI and the module declaring that is
          # only in the image build, so the running configuration has to repeat
          # it. Getting this wrong evaluates fine and fails at switch time.
          zeal-bootloader =
            holds "zeal would install GRUB to ${grub.device}, ESP mounted: ${toString (mounts ? "/boot")}"
              (grub.device == "nodev" && grub.efiSupport && mounts ? "/boot");
        };
    };
}
