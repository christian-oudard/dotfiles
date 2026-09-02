# The desktop layer of the user environment: Sway and the graphical
# applications, plus the dictation daemon. Sits on top of home/core.nix.
{ diktat }:

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # The dictation daemon: its own flake ships the package and the
    # systemd unit together.
    diktat.homeManagerModules.default
  ];

  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  # Sway desktop (config via chezmoi)
  home.packages = with pkgs; [
    sway
    foot
    bemenu
    j4-dmenu-desktop
    swaylock
    swaybg
    wl-clipboard
    wtype
    grim
    slurp
    brightnessctl
    mako
    libnotify
    batsignal
    i3status
    pulsemixer
    wev
    brave
    signal-desktop
    karere
    vesktop
    obsidian
  ];

  # The unit comes from the diktat flake; only the ceiling is this machine's,
  # since what the daemon holds is the model it was pointed at. Settles at
  # about 680 MB in use with that one, peaking near 735 MB on a full-length
  # utterance. This is a backstop against a runaway, not a working limit.
  systemd.user.services.diktat.Service.MemoryMax = "1500M";
}
