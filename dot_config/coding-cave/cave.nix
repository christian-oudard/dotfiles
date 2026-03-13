{
  inputs = {
    persist = "github:christian-oudard/persist";
  };

  config = { pkgs, persist, ... }: {
    plugins = [ persist ];

    packages = with pkgs; [
      # General
      tree eza nano direnv zsh neovim

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

    settings = {
      model = "opus";
      alwaysThinkingEnabled = true;
      promptSuggestionEnabled = false;
      effortLevel = "high";
    };
  };
}
