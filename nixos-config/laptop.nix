# Everything the laptops share that presupposes hardware: a screen, a
# battery, speakers, a disk this machine boots from. Imported by each host
# beside common.nix, and never exported; the zeal workstation takes only
# common.nix.
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

  # Group memberships the hardware and services below give meaning to.
  # Merges with common.nix's wheel.
  users.users.${username}.extraGroups = [
    "video"
    "networkmanager"
    "audio"
    "docker"
    "kvm"
    "dialout"
  ];

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

  # Make plain `nixos-rebuild` find this flake without --flake.
  # Out-of-store symlink: nixos-rebuild resolves /etc/nixos/flake.nix and
  # uses its directory as the flake, so it must point at the real repo file.
  # A wrapper flake written via .text lands in the store and resolves to
  # /nix/store, which is not a flake.
  environment.etc."nixos/flake.nix".source = "${homeDir}/code/dotfiles/nixos-config/flake.nix";

  environment.systemPackages = with pkgs; [
    wireguard-tools
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

  # The NixOS release the laptops were first installed with. Selects stateful
  # defaults; common.nix leaves it to each importer.
  system.stateVersion = "24.11";
}
