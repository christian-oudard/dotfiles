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

  config = { pkgs, persist, claude-plugins-official, agent-capabilities, ... }: {
    plugins = [
      persist

      # Official plugins
      { src = "${claude-plugins-official}/plugins/commit-commands"; }
      { src = "${claude-plugins-official}/plugins/code-simplifier"; }
      { src = "${claude-plugins-official}/plugins/frontend-design"; }

      # Agent capabilities
      { src = "${agent-capabilities}/audio_transcription"; }
      { src = "${agent-capabilities}/pdf_conversion"; }
      { src = "${agent-capabilities}/website_mirroring"; }
    ];

    packages = with pkgs; [
      # General
      tree eza nano direnv zsh neovim diff-so-fancy

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
