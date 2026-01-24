# Home Manager configuration
# Packages only - all dotfiles managed by chezmoi
{ username ? "christian" }:

{ config, pkgs, lib, ... }:

let
  homeDir = "/home/${username}";
in {
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Cursor theme (HiDPI)
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # All packages - chezmoi manages all config files
  home.packages = with pkgs; [
    # 1Password CLI
    _1password-cli

    # Browser
    brave

    # Sway desktop (config via chezmoi)
    sway
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
    i3status
    i3status-rust
    foot
    pulsemixer

    # Terminal utilities
    zsh
    tmux
    tmuxPlugins.gruvbox
    bash
    python3
    uv
    claude-code
    nodejs
    fd
    fzf
    ripgrep
    jq
    htop
    diff-so-fancy
    chezmoi
    python3Packages.grip

    # Git
    git
    gnupg
    gh

    # Remote access
    ngrok

    # Secrets decryption
    age

    # LSP servers for neovim
    pyright
    rust-analyzer
    ruff
    typescript-language-server
  ];

  # Direnv - this one is fine, doesn't conflict
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Neovim - plugins via home-manager, config via chezmoi
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
    ];
  };
}
