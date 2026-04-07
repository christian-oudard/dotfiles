# Shared NixOS configuration for all hosts
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Boot
  boot.loader.systemd-boot.enable = true;
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
  users.users.christian = {
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

  # Lid close behavior: lock screen instead of suspend
  services.logind.settings.Login.HandleLidSwitch = "lock";

  # Power button: short press hibernates, long press (5s) powers off
  services.logind.settings.Login.HandlePowerKey = "hibernate";
  services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";
  powerManagement.enable = true;

  # Weekly nix garbage collection: prune generations older than 30 days
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Graphics (needed for Steam / gaming)
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Steam
  programs.steam.enable = true;

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
        user = "christian";
      };
    };
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "christian";
    dataDir = "/home/christian";
    configDir = "/home/christian/.config/syncthing";
    databaseDir = "/home/christian/.local/state/syncthing";
    openDefaultPorts = true; # TCP 22000 + UDP 22000/21027
  };

  # Docker
  virtualisation.docker.enable = true;

  # SSH: use absolute path so root (nixos-rebuild) can fetch private flake inputs
  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile /home/christian/.ssh/christian_dedekind
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
    "d /tmp/claude 0755 christian users -"
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
