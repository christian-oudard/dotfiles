{
  username,
  homeDir,
  persist,
  claude-plugins-official,
}:

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports =
    let
      args = { inherit persist claude-plugins-official; };
    in
    [
      ./modules/neovim.nix
      (import ./modules/claude.nix args).module
    ];
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  home.pointerCursor = {
    enable = true;
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
    codex-cli
    socat
    bubblewrap
    libseccomp
    python3
    uv
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
    vesktop
    obsidian

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

  # The unit comes from the diktat flake; only the ceiling is this machine's,
  # since what the daemon holds is the model it was pointed at. Settles at
  # about 680 MB in use with that one, peaking near 735 MB on a full-length
  # utterance. This is a backstop against a runaway, not a working limit.
  systemd.user.services.diktat.Service.MemoryMax = "1500M";

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
