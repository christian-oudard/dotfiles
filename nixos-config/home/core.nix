# The headless part of the user environment: shells, editor, language
# tooling, terminal utilities. Everything that is useful over SSH and nothing
# that needs a screen; the graphical layer is home/desktop.nix.
#
# Exported from the flake as homeModules.core and imported by hosts outside
# this repository, so nothing here may reference the private coding-cave
# input.
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
