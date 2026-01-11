# Home Manager - packages only (no dotfile management)
{ config, pkgs, lib, ... }:

{
  home.username = "christian";
  home.homeDirectory = "/home/christian";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Packages only - no config file generation
  home.packages = with pkgs; [
    # Browser
    brave

    # Sway desktop
    foot
    bemenu
    j4-dmenu-desktop
    swaylock
    swaybg
    wl-clipboard
    grim
    slurp
    brightnessctl
    mako
    i3status

    # Terminal utilities
    tmux
    neovim
    nodejs
    direnv
    fd
    fzf
    ripgrep
    jq
    htop
    diff-so-fancy

    # 1Password CLI
    _1password-cli

    # Git signing
    gnupg
  ];

  # Direnv with nix-direnv (doesn't conflict with chezmoi - creates ~/.config/direnv/lib/)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
