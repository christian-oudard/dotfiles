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
    diktat
    ruff
    pyright
    nodejs
    jq
    typescript-language-server
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

  # Dictation daemon. It holds the speech model in RAM for the whole session so
  # the first toggle records with no load delay, and it never exits on its own.
  # Sway starts it, since that is where WAYLAND_DISPLAY and SWAYSOCK come from.
  # ExecStart pins a store path, so a diktat upgrade changes this unit and
  # home-manager's sd-switch restarts it during activation.
  systemd.user.services.diktat = {
    Unit.Description = "diktat dictation daemon";
    Service = {
      ExecStart = "${pkgs.diktat}/bin/diktat-daemon";
      Restart = "on-failure";
      RestartSec = 2;
      # Settles at about 680 MB in use, peaking near 735 MB on a full-length
      # utterance. This is a backstop against a runaway, not a working limit.
      MemoryMax = "1500M";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

}
