{
  persist,
  claude-plugins-official,
}:

rec {
  # Static plugin paths (persist is added in each module because it needs pkgs).
  pluginPaths = [
    "${claude-plugins-official}/plugins/commit-commands"
    "${claude-plugins-official}/plugins/code-simplifier"
    "${claude-plugins-official}/plugins/frontend-design"
  ];

  # LSP servers consumed by programs.claude-code.lspServers. The
  # home-manager module synthesizes a plugin dir with .lsp.json and
  # registers it via --plugin-dir. The upstream *-lsp plugins from
  # claude-plugins-official are dropped: they're README-only stubs and the
  # marketplace.json lspServers key is not propagated at install time
  # (anthropics/claude-code#16219).
  lspServers = {
    pyright = {
      command = "pyright-langserver";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
    rust-analyzer = {
      command = "rust-analyzer";
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
    gopls = {
      command = "gopls";
      extensionToLanguage = {
        ".go" = "go";
      };
    };
    typescript = {
      command = "typescript-language-server";
      args = [ "--stdio" ];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
        ".mts" = "typescript";
        ".cts" = "typescript";
        ".mjs" = "javascript";
        ".cjs" = "javascript";
      };
    };
    lean = {
      command = "lean";
      args = [ "--server" ];
      extensionToLanguage = {
        ".lean" = "lean";
      };
    };
  };

  # Custom skills, one <name>/SKILL.md per directory under claude/skills/,
  # surfacing as /<name>. Drop a new skill in there, no nix change needed.
  # The host passes the directory straight to programs.claude-code.skills;
  # the cave consumes skillsSrc as a bundle src (which expects a directory
  # containing skills/).
  skillsSrc = ./claude;
  skills = skillsSrc + "/skills";

  # Bell hooks are added per-consumer via bellHooks, since the bell command
  # is environment-specific.
  settings = {
    model = "fable";
    effortLevel = "high";
    alwaysThinkingEnabled = true;
    promptSuggestionEnabled = false;
    tui = "default";
    spinnerVerbs = {
      mode = "replace";
      verbs = [ "Working" ];
    };
    env = {
      TMPPREFIX = "/tmp/claude/zsh";
      CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    };
    permissions = {
      allow = [
        "Edit(/tmp/claude/**)"
        "Bash(rg:*)"
        "Bash(ls:*)"
        "Bash(fd:*)"
        "Bash(find:*)"
        "Bash(tree:*)"
        "Bash(file:*)"
        "Bash(stat:*)"
        "Bash(realpath:*)"
        "Bash(dirname:*)"
        "Bash(basename:*)"
        "Bash(mkdir:*)"
        "Bash(diff:*)"
        "Bash(sort:*)"
        "Bash(uniq:*)"
        "Bash(wc:*)"
        "Bash(date:*)"
        "Bash(which:*)"
        "Bash(whereis:*)"
        "Bash(type:*)"
        "Bash(env:*)"
        "Bash(pwd:*)"
        "Bash(id:*)"
        "Bash(whoami:*)"
        "Bash(uname:*)"
        "Bash(git:status:*)"
        "Bash(git:log:*)"
        "Bash(git:diff:*)"
        "Bash(git:branch:)"
        "Bash(git:branch:-a:*)"
        "Bash(git:branch:-r:*)"
        "Bash(git:branch:--list:*)"
        "Bash(git:branch:-v:*)"
        "Bash(git:show:*)"
        "Bash(git:blame:*)"
        "Bash(git:rev-parse:*)"
        "Bash(git:ls-files:*)"
        "Bash(git:ls-tree:*)"
        "Bash(git:cat-file:*)"
        "Bash(git:config --get:*)"
        "Bash(git:config --list:*)"
        "Bash(git:remote -v:*)"
        "Bash(git:remote get-url:*)"
        "Bash(git:remote show:*)"
        "WebSearch"
        "WebFetch(domain:localhost)"
        "WebFetch(domain:api.anthropic.com)"
        "WebFetch(domain:www.anthropic.com)"
        "WebFetch(domain:docs.anthropic.com)"
        "WebFetch(domain:code.claude.com)"
        "WebFetch(domain:mcp.context7.com)"
        "WebFetch(domain:en.wikipedia.org)"
        "WebFetch(domain:github.com)"
        "WebFetch(domain:raw.githubusercontent.com)"
        "WebFetch(domain:api.github.com)"
        "WebFetch(domain:gist.github.com)"
        "WebFetch(domain:codeload.githubusercontent.com)"
        "WebFetch(domain:release-assets.githubusercontent.com)"
        "WebFetch(domain:wiki.archlinux.org)"
        "WebFetch(domain:search.nixos.org)"
        "WebFetch(domain:channels.nixos.org)"
        "WebFetch(domain:docs.python.org)"
        "WebFetch(domain:pypi.org)"
        "WebFetch(domain:files.pythonhosted.org)"
        "WebFetch(domain:doc.rust-lang.org)"
        "WebFetch(domain:docs.rs)"
        "WebFetch(domain:crates.io)"
        "WebFetch(domain:lib.rs)"
        "WebFetch(domain:leanprover.github.io)"
        "WebFetch(domain:leanprover-community.github.io)"
        "WebFetch(domain:lean-lang.org)"
        "WebFetch(domain:reservoir.lean-lang.org)"
        "WebFetch(domain:release.lean-lang.org)"
        "WebFetch(domain:haskell.org)"
        "WebFetch(domain:hackage.haskell.org)"
        "WebFetch(domain:hoogle.haskell.org)"
        "WebFetch(domain:go.dev)"
        "WebFetch(domain:pkg.go.dev)"
        "WebFetch(domain:golang.org)"
        "WebFetch(domain:nodejs.org)"
        "WebFetch(domain:pnpm.io)"
        "WebFetch(domain:registry.npmjs.org)"
        "WebFetch(domain:developer.mozilla.org)"
        "WebFetch(domain:typescriptlang.org)"
        "WebFetch(domain:man7.org)"
        "WebFetch(domain:data1.fullyjustified.net)"
        "WebFetch(domain:relay.fullyjustified.net)"
        "mcp__context7__resolve-library-id"
        "mcp__context7__query-docs"
        "mcp__c4ai-sse__md"
        "mcp__c4ai-sse__html"
        "mcp__c4ai-sse__screenshot"
        "mcp__c4ai-sse__pdf"
        "mcp__c4ai-sse__execute_js"
        "mcp__c4ai-sse__crawl"
        "mcp__c4ai-sse__ask"
      ];
      deny = [
        "Read(~/.keys/**)"
        "Read(~/.ssh/**)"
        "Read(~/.gnupg/**)"
        "Bash(ag:*)"
        "Bash(curl:*)"
        "Bash(wget:*)"
        "Bash(nc:*)"
        "Bash(netcat:*)"
        "Bash(ncat:*)"
        "Bash(socat:*)"
        "Bash(ssh:*)"
        "Bash(scp:*)"
        "Bash(rsync:*)"
        "Bash(ftp:*)"
        "Bash(sftp:*)"
        "Bash(sudo:*)"
        "Bash(su:*)"
        "Bash(doas:*)"
        "Bash(pkexec:*)"
        "Bash(pip:*)"
        "Bash(pip3:*)"
        "Bash(npm:*)"
        "Bash(npx:*)"
        "Bash(yarn:*)"
        "Bash(shred:*)"
        "Bash(dd:*)"
        "Bash(mkfs:*)"
        "Bash(fdisk:*)"
        "Bash(parted:*)"
        "Bash(reboot:*)"
        "Bash(shutdown:*)"
        "Bash(poweroff:*)"
        "Bash(halt:*)"
        "Bash(mount:*)"
        "Bash(umount:*)"
      ];
    };
  };

  # persist's derivation is both the plugin directory and the CLI. Listing it
  # as a plugin both registers it and (via the home.packages line below) puts
  # bin/persist on the login PATH, so the stop bell's bare `persist active`
  # resolves in a hook (hooks get a PATH without plugin bins).
  persistPkg = pkgs: import persist { inherit pkgs; };
  pluginsFor = pkgs: pluginPaths ++ [ (persistPkg pkgs) ];

  # Bell triggers for "agent needs you" moments: the turn ending (Stop), a
  # question (AskUserQuestion), or a permission prompt. The Notification
  # matcher is the notification_type, scoped to permission_prompt so the 60s
  # idle_prompt does not ring. The bell command differs per environment
  # (host uses /proc/$PPID, the cave uses cav-host), so it is passed in.
  bellHooks =
    bellCmd:
    let
      # Stop also fires on iterations that a persist loop re-injects, so
      # stay silent while `persist active` reports a live session. persist
      # ends a session with a final summarize turn, so the loop's last stop
      # still rings; `persist active` also treats an expired-but-uncleaned
      # session as inactive, so a stale state file does not mute the bell.
      stopCmd = "persist active || ${bellCmd}";
    in
    {
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = stopCmd;
            }
          ];
        }
      ];
      PreToolUse = [
        {
          matcher = "AskUserQuestion";
          hooks = [
            {
              type = "command";
              command = bellCmd;
            }
          ];
        }
      ];
      Notification = [
        {
          matcher = "permission_prompt";
          hooks = [
            {
              type = "command";
              command = bellCmd;
            }
          ];
        }
      ];
    };

  # Home-manager module that wires the data above through programs.claude-code
  # and writes an editable settings.json on activation. Other consumers can
  # ignore this and read pluginsFor / lspServers / settings directly.
  module =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Ring the terminal that launched Claude. PID 1 is systemd, so the
      # terminal is $PPID's stdout.
      bellCmd = "printf '\\a' > /proc/$PPID/fd/1";
    in
    {
      # Install plugins shipped as packages (persist); path-string plugins
      # have no package to install, so filter them out.
      home.packages = builtins.filter lib.isDerivation (pluginsFor pkgs);

      programs.claude-code = {
        enable = true;
        package = pkgs.claude-code;
        plugins = pluginsFor pkgs;
        inherit lspServers skills;
      };

      home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.jq}/bin/jq . \
          ${
            pkgs.writeText "claude-settings.json" (builtins.toJSON (settings // { hooks = bellHooks bellCmd; }))
          } \
          > "$HOME/.claude/settings.json"
        chmod 644 "$HOME/.claude/settings.json"
      '';
    };
}
