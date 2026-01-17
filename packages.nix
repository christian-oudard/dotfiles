# Packages for home.nix
{ pkgs }:

with pkgs; [
  # 1Password CLI
  _1password-cli

  # Browser
  brave

  # Sway desktop (some managed via programs.* in home.nix)
  bemenu
  j4-dmenu-desktop
  swaylock
  swaybg
  wl-clipboard
  grim
  slurp
  brightnessctl

  # Terminal utilities (some managed via programs.* in home.nix)
  python3
  nodejs
  fd
  fzf
  ripgrep
  jq
  htop
  diff-so-fancy

  # Git signing
  gnupg

  # Secrets decryption
  age

  # LSP servers for neovim
  pyright
  rust-analyzer
  ruff
  typescript-language-server
]
