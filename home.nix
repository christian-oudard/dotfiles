# Home Manager configuration
# Usage: import ./home.nix { username = "christian"; }
{ username ? "christian" }:

{ config, pkgs, lib, secretsPath, ... }:

let
  homeDir = "/home/${username}";

  # Gruvbox color palette (no # prefix - foot needs bare hex)
  c = {
    bg = "282828";
    bg1 = "3c3836";
    bg2 = "504945";
    fg = "ebdbb2";
    gray = "928374";
    red = "cc241d";
    green = "98971a";
    yellow = "d79921";
    blue = "458588";
    purple = "b16286";
    aqua = "689d6a";
    orange = "d65d0e";
    bright = {
      red = "fb4934";
      green = "b8bb26";
      yellow = "fabd2f";
      blue = "83a598";
      purple = "d3869b";
      aqua = "8ec07c";
      orange = "fe8019";
    };
  };
  # Add # prefix for configs that need it (mako)
  hash = v: "#${v}";
in {
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Agenix secrets configuration
  age.identityPaths = [ "${homeDir}/.keys/age_key.txt" ];
  age.secrets = {
    zshrc-private = {
      file = "${secretsPath}/zshrc-private.age";
      path = "${homeDir}/.config/zsh/.zshrc_private";
    };
    git-config = {
      file = "${secretsPath}/git-config.age";
      path = "${homeDir}/.config/git/config.local";
    };
    modal-config = {
      file = "${secretsPath}/modal.toml.age";
      path = "${homeDir}/.config/modal/modal.toml";
    };
    ngrok-config = {
      file = "${secretsPath}/ngrok.yml.age";
      path = "${homeDir}/.config/ngrok/ngrok.yml";
    };
  };

  # Packages (programs.* manages: foot, mako, i3status, tmux, neovim, direnv, git, zsh)
  home.packages = with pkgs; [
    # 1Password CLI
    _1password-cli

    # Browser
    brave

    # Sway desktop
    bemenu
    j4-dmenu-desktop
    swaylock
    swaybg
    wl-clipboard
    grim
    slurp
    brightnessctl

    # Terminal utilities
    bash
    python3
    claude-code
    nodejs
    fd
    fzf
    ripgrep
    jq
    htop
    diff-so-fancy
    chezmoi
    python3Packages.grip

    # Git signing
    gnupg
    gh

    # Secrets decryption
    age

    # LSP servers for neovim
    pyright
    rust-analyzer
    ruff
    typescript-language-server
  ];

  # Direnv (with nix-direnv for better nix integration)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Zsh
  programs.zsh = {
    enable = true;
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    history = {
      path = "${config.xdg.configHome}/zsh/.zhistory";
      size = 100000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Zsh options (matching chezmoi setopt)
    autocd = true;
    defaultKeymap = "emacs";

    # Environment variables (.zshenv equivalent)
    sessionVariables = {
      EDITOR = "nvim";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
      VIRTUAL_ENV_DISABLE_PROMPT = "1";
      AUTOENV_ENABLE_LEAVE = "1";
      FZF_DEFAULT_COMMAND = "fd --type f --hidden";
      GRIM_DEFAULT_DIR = "$HOME/screenshots";
      PNPM_HOME = "$HOME/.local/bin";
      LIBVIRT_DEFAULT_URI = "qemu:///system";
      MODAL_CONFIG_PATH = "$HOME/.config/modal/modal.toml";
      ENABLE_LSP_TOOL = "1";
    };

    shellAliases = {
      # ls variants
      ls = "ls --color=auto";
      i = "ls";
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      # Safe defaults
      cp = "cp -i";
      mv = "mv -i";
      # Tools
      diff = "diff --color=auto";
      grep = "grep --color=auto";
      ip = "ip -color=auto";
      less = "less -w";
      tar = "tar --keep-old-files";
      vim = "nvim";
      cal = "cal --monday --year --week";
    };

    initContent = lib.mkMerge [
      # Run first: gruvbox colors and tmux auto-start
      (lib.mkBefore ''
        # Set terminal colors (gruvbox.sh handles tmux pass-through)
        if [[ -n "$PS1" ]] && [[ -f $HOME/.config/gruvbox.sh ]]; then
            source $HOME/.config/gruvbox.sh
        fi

        # Auto-start tmux on Wayland
        if [[ -n $WAYLAND_DISPLAY ]] && [[ -z $TMUX ]] && [[ -z $NO_TMUX ]]; then
            exec env tmux new-session -A -s 0
        fi
      '')

      # Main config
      ''
        # GPG TTY for signing
        export GPG_TTY=$(tty)

        # PATH additions
        typeset -U path PATH
        path+=(~/bin ~/.local/bin ~/.cargo/bin ~/.npm-global/bin)
        export PATH

        # Additional zsh options not covered by home-manager
        setopt \
          extended_glob \
          noglobdots \
          correct \
          completeinword \
          longlistjobs \
          notify \
          hash_list_all \
          nohup \
          auto_pushd \
          pushd_ignore_dups \
          prompt_subst \
          nobeep \
          noshwordsplit \
          noclobber \
          unset

        # Completion
        autoload -Uz compinit
        compinit
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' completer _expand_alias _complete _ignored

        # History search
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search

        # Prompt
        function hline {
          print ''${(pl:$COLUMNS::\u2500:)}
        }
        function last_exit_code() {
          local EXIT_CODE=$?
          if [[ $EXIT_CODE -ne 0 ]]; then
            echo "[$EXIT_CODE] "
          fi
        }
        function venv_status {
          if [[ -n "$VIRTUAL_ENV" ]]; then
            echo "(venv) "
          fi
        }
        function width {
          echo $(( COLUMNS - 24 ))
        }
        function ssh_hostname {
          if [[ -n "$SSH_TTY" ]]; then
            echo "%n@%M:"
          fi
        }
        PROMPT='%F{237}$(hline)
%K{237}%F{4}$%f%k '
        PROMPT2='%K{237}%F{4}%_>%f%k '
        RPROMPT='%F{5}$(last_exit_code)$(venv_status)%$(width)<…<$(ssh_hostname)%~%<<%f'

        # Key bindings
        bindkey -e
        bindkey '^P' up-line-or-beginning-search
        bindkey '^N' down-line-or-beginning-search

        # Sudo wrapper - refresh timeout when not in pipe
        sudo() {
            if [[ -t 0 ]]; then
                command sudo -v
            fi
            command sudo "$@"
        }

        # Source private config (API keys, tokens)
        [[ -f ~/.config/zsh/.zshrc_private ]] && source ~/.config/zsh/.zshrc_private
      ''
    ];
  };

  # Tmux - basic options here, full config in ./tmux/tmux.conf
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    prefix = "C-t";
    plugins = with pkgs.tmuxPlugins; [
      gruvbox
    ];
    extraConfig = builtins.readFile ./tmux/tmux.conf;
  };

  # Neovim - plugins via home-manager, config files via xdg.configFile
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      vim-commentary
      vim-surround
      vim-fugitive
      ultisnips
      vim-auto-save
      nvim-lspconfig
      vim-python-pep8-indent
      plenary-nvim
      nvim-web-devicons
      trouble-nvim
      telescope-nvim
      bufferline-nvim
    ];
  };

  # Neovim config files (from ./nvim/ directory)
  xdg.configFile = {
    "nvim/init.vim".source = ./nvim/init.vim;
    "nvim/lua/plugins.lua".source = ./nvim/lua/plugins.lua;
    "nvim/lua/lsp.lua".source = ./nvim/lua/lsp.lua;
    "nvim/UltiSnips/all.snippets".source = ./nvim/UltiSnips/all.snippets;
    "gruvbox.sh".source = ./config/gruvbox.sh;
  };

  # Scripts in ~/bin
  home.file."bin/claude_notify_hook" = {
    source = ./bin/claude_notify_hook;
    executable = true;
  };

  # Foot terminal
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "NotoSansM Nerd Font:size=11";
        dpi-aware = "no";
      };
      colors = {
        background = c.bg;
        foreground = c.fg;
        regular0 = c.bg;
        regular1 = c.red;
        regular2 = c.green;
        regular3 = c.yellow;
        regular4 = c.blue;
        regular5 = c.purple;
        regular6 = c.aqua;
        regular7 = c.gray;
        bright0 = c.gray;
        bright1 = c.bright.red;
        bright2 = c.bright.green;
        bright3 = c.bright.yellow;
        bright4 = c.bright.blue;
        bright5 = c.bright.purple;
        bright6 = c.bright.aqua;
        bright7 = c.fg;
      };
    };
  };

  # i3status - config file in ./i3status/config
  programs.i3status.enable = true;
  xdg.configFile."i3status/config".source = lib.mkForce ./i3status/config;

  # Mako notifications
  services.mako = {
    enable = true;
    settings = {
      background-color = hash c.bg;
      text-color = hash c.fg;
      border-color = hash c.blue;
      default-timeout = 5000;
    };
  };

  # Sway - config file in ./sway/config
  wayland.windowManager.sway = {
    enable = true;
    config = null;  # Disable config generation, use file instead
  };
  xdg.configFile."sway/config".source = lib.mkForce ./sway/config;
  xdg.configFile."sway/scripts/update_monitor_position.py" = {
    source = ./sway/scripts/update_monitor_position.py;
    executable = true;
  };

  # Git
  programs.git = {
    enable = true;
    settings.user = {
      name = "Christian Oudard";
      email = "christian.oudard@gmail.com";
    };
    includes = [
      { path = "${config.home.homeDirectory}/.config/git/config.local"; }
    ];
  };
}
