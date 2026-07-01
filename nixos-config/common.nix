# Shared NixOS configuration for all hosts
{
  config,
  lib,
  pkgs,
  username,
  homeDir,
  ...
}:

{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking (common settings, hostname set per-host)
  networking.networkmanager.enable = true;

  # Locale and timezone
  time.timeZone = "US/Mountain";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console (TTY)
  console = {
    font = "ter-i32b";
    useXkbConfig = true;
    packages = [ pkgs.terminus_font ];
  };

  # XKB keyboard layout (used by console and Sway)
  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
    options = "ctrl:swapcaps";
  };

  # User accounts
  users.users.${username} = {
    uid = 1000;
    isNormalUser = true;
    homeMode = "700";
    extraGroups = [
      "wheel"
      "video"
      "networkmanager"
      "audio"
      "docker"
      "kvm"
      "dialout"
    ];
    shell = pkgs.zsh;
  };

  # Sudo: ask for password, cache 15 minutes globally across all terminals
  security.sudo = {
    wheelNeedsPassword = true;
    extraConfig = ''
      Defaults timestamp_type=global
      Defaults timestamp_timeout=15
      Defaults lecture=never
    '';
  };

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Printing: CUPS with driverless IPP, network discovery via mDNS
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Flipper Zero serial access (CDC ACM)
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", MODE="0660", GROUP="dialout"
  '';

  # Lid close behavior: lock screen instead of suspend
  services.logind.settings.Login.HandleLidSwitch = "lock";

  # Power button: short press hibernates, long press (5s) powers off
  services.logind.settings.Login.HandlePowerKey = "hibernate";
  services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";
  powerManagement.enable = true;

  # Auto-hibernate on critically low battery (kernel cuts power around 3-4%)
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 8;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # Daily nix garbage collection: prune generations older than 14 days
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  # Deduplicate the store, and let the daemon GC under disk pressure during
  # builds so the root partition never fills up between scheduled runs.
  nix.optimise.automatic = true;
  nix.settings = {
    min-free = 5 * 1024 * 1024 * 1024; # start freeing when < 5G free
    max-free = 20 * 1024 * 1024 * 1024; # free up to 20G
  };

  # Graphics.
  hardware.graphics.enable = true;

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Keyring (Secret Service API for Python keyring, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Auto-login and start Sway via greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd sway";
        user = "greeter";
      };
      initial_session = {
        command = "sway";
        user = username;
      };
    };
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = homeDir;
    configDir = "${homeDir}/.config/syncthing";
    databaseDir = "${homeDir}/.local/state/syncthing";
    openDefaultPorts = true; # TCP 22000 + UDP 22000/21027
  };

  # Docker
  virtualisation.docker.enable = true;

  # SSH: use absolute path so root (nixos-rebuild) can fetch private flake inputs
  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ${homeDir}/.ssh/christian_dedekind
  '';

  # Shells
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # nix-ld for running pip-installed packages with C extensions.
  # Project-specific libs (e.g. CUDA) belong in per-project devShells, not here.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    portaudio
  ];

  # Create /bin/bash symlink for scripts with hardcoded shebangs
  system.activationScripts.binbash = ''
    ln -sf /run/current-system/sw/bin/bash /bin/bash
  '';

  # uv's standalone Python expects CA certs at /etc/ssl/cert.pem, which NixOS
  # doesn't create. Symlink it to the NixOS CA bundle so SSL works in uv venvs.
  environment.etc."ssl/cert.pem".source = "/etc/ssl/certs/ca-bundle.crt";

  # Make plain `nixos-rebuild` find this flake without --flake.
  # Out-of-store symlink: nixos-rebuild resolves /etc/nixos/flake.nix and
  # uses its directory as the flake, so it must point at the real repo file.
  # A wrapper flake written via .text lands in the store and resolves to
  # /nix/store, which is not a flake.
  environment.etc."nixos/flake.nix".source = "${homeDir}/code/dotfiles/nixos-config/flake.nix";

  # System packages (minimal - user packages in home-manager)
  environment.systemPackages = with pkgs; [
    git
    nano
    acl
    wireguard-tools
    gcc
    pkg-config
  ];

  # Fonts
  fonts.packages = with pkgs; [
    terminus_font
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    nerd-fonts.noto
  ];

  # XDG Portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Temp directory for Claude Code sandbox (TMPDIR=/tmp/claude)
  systemd.tmpfiles.rules = [
    "d /tmp/claude 0755 ${username} users -"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "24.11";
}
