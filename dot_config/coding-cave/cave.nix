{
  inputs = {
    persist = "github:christian-oudard/persist";
  };

  config = { pkgs, persist, ... }: {
    packages = with pkgs; [
      python3 uv perl tree eza nano direnv zsh
    ];

    env = {
      EDITOR = "${pkgs.nano}/bin/nano";
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
