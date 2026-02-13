# Shared NixOS configuration for all hosts
{ config, lib, pkgs, ... }:

{
  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking (common settings, hostname set per-host)
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
  boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;
  networking.getaddrinfo.precedence = {
    "::1/128" = 50;
    "::ffff:0:0/96" = 100;  # Prefer IPv4
    "::/0" = 40;
  };

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
    extraGroups = [ "wheel" "video" "networkmanager" "audio" "docker" ];
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

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

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

  # Docker
  virtualisation.docker.enable = true;

  # Shells
  programs.zsh.enable = true;
  programs.bash.enable = true;

  # nix-ld for running pip-installed packages with C extensions
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    portaudio
  ];

  # Create /bin/bash symlink for scripts with hardcoded shebangs
  system.activationScripts.binbash = ''
    ln -sf /run/current-system/sw/bin/bash /bin/bash
  '';

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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
