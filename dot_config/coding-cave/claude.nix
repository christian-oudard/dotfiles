{ persist, claude-plugins-official, agent-capabilities }:

{
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

  settings = {
    model = "opus";
    alwaysThinkingEnabled = true;
    promptSuggestionEnabled = false;
    effortLevel = "high";
  };
}
