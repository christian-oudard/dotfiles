{
  inputs = {
    persist = "github:christian-oudard/persist";
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official";
      flake = false;
    };
    agent-capabilities = {
      url = "git+ssh://git@github.com/christian-oudard/agent-capabilities";
      flake = false;
    };
  };

  config = { pkgs, persist, claude-plugins-official, agent-capabilities, ... }:
  let
    claude = import ./claude.nix { inherit persist claude-plugins-official agent-capabilities; };
  in {
    inherit (claude) plugins settings;

    files = {
      ".config/direnv/direnvrc" = "source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
    };

    packages = with pkgs; [
      # General
      tree eza nano direnv nix-direnv zsh neovim diff-so-fancy

      # Python
      python3 python3Packages.pytest uv

      # Haskell
      ghc cabal-install stack

      # JS/TypeScript
      nodejs typescript

      # Rust
      cargo rustc rustfmt clippy
    ];

    env = {
      EDITOR = "nvim";
    };
  };
}
