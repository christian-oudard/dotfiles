# The headless part of the user environment: shells, editor, language
# tooling, terminal utilities. Everything that is useful over SSH and nothing
# that needs a screen; the graphical layer is home/desktop.nix.
#
# Taken by every host.
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
      ../modules/neovim.nix
      (import ../modules/claude.nix args).module
    ];
  home.username = username;
  home.homeDirectory = homeDir;
  # No home.stateVersion here. It records when a profile was first activated,
  # which each importer knows and this file does not.

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
    gtrash

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
    jh

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
    viddy
    wget
    unzip
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Trash is the undo for tp; it is not backed up, so keep it for 30 days.
  systemd.user.services.trash-prune = {
    Unit.Description = "Delete trash older than 30 days";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.gtrash}/bin/gtrash prune --force --day 30";
    };
  };
  systemd.user.timers.trash-prune = {
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
