# NixOS system configuration for X1 Carbon
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "x1carbon";
  networking.networkmanager.enable = true;

  # Locale and timezone
  time.timeZone = "US/Mountain";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console (TTY)
  console = {
    font = "ter-i32b";
    useXkbConfig = true;  # Use XKB settings (dvorak, ctrl:swapcaps) on TTY
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
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" "audio" ];
    shell = pkgs.zsh;
  };


  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

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

  # Zsh system-wide
  programs.zsh.enable = true;

  # System packages (minimal - user packages in home-manager)
  environment.systemPackages = with pkgs; [
    git
    nano

    # Claude Code sandbox
    socat
    bubblewrap
  ];

  # Fonts
  fonts.packages = with pkgs; [
    terminus_font
    noto-fonts
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
