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
      (import ./claude.nix args).module
      (import ./gen-cave.nix args)
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
    zoom-us

    # Terminal utilities
    diff-so-fancy
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

    # Programming
    git
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
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # init.lua is managed by chezmoi. home-manager needs to generate some vim config, which is put
  # into hm-generated.lua, and imported from init.lua.
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
  xdg.configFile."nvim/lua/hm-generated.lua".text = config.programs.neovim.initLua;

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
      vim-nix
      lean-nvim
    ];
  };
}
