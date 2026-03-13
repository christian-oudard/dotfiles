{
  inputs = {
    persist = "github:christian-oudard/persist";
  };

  config = { pkgs, persist, ... }: {
    plugins = [ persist ];

    packages = with pkgs; [
      python3 uv perl tree eza nano direnv zsh neovim
    ];

    env = {
      EDITOR = "nvim";
    };

    settings = {
      model = "opus";
      reasoning_effort = "high";
      alwaysThinkingEnabled = true;
      promptSuggestionEnabled = false;
      effortLevel = "medium";
    };
  };
}
