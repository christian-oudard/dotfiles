{ username ? "christian" }:

{ config, pkgs, lib, ... }:

let
  homeDir = "/home/${username}";
in {
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
    brave

    # Terminal utilities
    diff-so-fancy
    dust
    fd
    fzf
    htop
    imagemagick
    ngrok
    restic
    ripgrep
    tree
    wget

    # Programming
    git
    gh
    claude-code
    socat
    bubblewrap
    python3
    uv
    ruff
    pyright
    nodejs
    jq
    typescript-language-server
    rust-analyzer
    elan
    podman
    tinyproxy

    # Libraries
    cairo.dev
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      vim-commentary
      vim-surround
      vim-fugitive
      ultisnips
      vim-auto-save
      nvim-lspconfig
      vim-python-pep8-indent
      plenary-nvim
      nvim-web-devicons
      trouble-nvim
      telescope-nvim
      bufferline-nvim
      lean-nvim
    ];
  };
}
