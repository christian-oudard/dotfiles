{ config, pkgs, lib, ... }:

{
  home.username = "agent";
  home.homeDirectory = "/home/agent";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    git
    gh
    claude-code
    ripgrep
    fd
    tree
    jq
    python3
    uv
    nodejs
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "agent";
      user.email = "agent@localhost";
      safe.directory = "*";
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"
    '';
  };
}
