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
    keyMap = "dvorak";
    packages = [ pkgs.terminus_font ];
  };

  # User account
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
