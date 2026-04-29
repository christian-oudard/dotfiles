{
  username ? "christian",
  persist,
  claude-plugins-official,
  agent-capabilities,
}:

{
  config,
  pkgs,
  lib,
  ...
}:

let
  homeDir = "/home/${username}";
in
{
  imports =
    let
      args = { inherit persist claude-plugins-official agent-capabilities; };
    in
    [
      ./modules/neovim.nix
      (import ./modules/claude.nix args).module
    ];
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    # Basic
    zsh
    bash
    tmux
    tmuxPlugins.gruvbox
    eza
    uutils-coreutils-noprefix

    # Dotfiles
    chezmoi
    age
    gnupg
    _1password-cli

    # Backup and sync
    restic
    rclone
    rsync

    # Programming
    jujutsu
    gh
    socat
    bubblewrap
    libseccomp
    python3
    uv
    whisper-dictation
    ruff
    pyright
    nodejs
    jq
    typescript-language-server
    nil
    nixfmt
    rustup
    google-cloud-sdk
    sqlite

    # Sway desktop (config via chezmoi)
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
    zoom-us
    steam
    steam-run

    # Terminal utilities
    dust
    fd
    fzf
    htop
    imagemagick
    ngrok
    ripgrep
    tree
    ttyd
    wget
    unzip
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
