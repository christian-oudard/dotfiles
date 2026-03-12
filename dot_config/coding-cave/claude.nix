{
  inputs = {
    persist = "github:christian-oudard/persist";
  };

  config = { persist }: {
    plugins.persist = persist.plugin.x86_64-linux;

    settings = {
      model = "opus";
      reasoning_effort = "high";
      alwaysThinkingEnabled = true;
      promptSuggestionEnabled = false;
      effortLevel = "medium";
    };
  };
}
