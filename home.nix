# Home Manager configuration
# Usage: import ./home.nix { username = "christian"; }
{ username ? "christian" }:

{ config, pkgs, lib, secretsPath, ... }:

let
  homeDir = "/home/${username}";

  # Gruvbox color palette
  colors = {
    bg = "#282828";
    bg1 = "#3c3836";
    bg2 = "#504945";
    fg = "#ebdbb2";
    gray = "#928374";
    red = "#cc241d";
    green = "#98971a";
    yellow = "#d79921";
    blue = "#458588";
    purple = "#b16286";
    aqua = "#689d6a";
    orange = "#d65d0e";
    bright = {
      red = "#fb4934";
      green = "#b8bb26";
      yellow = "#fabd2f";
      blue = "#83a598";
      purple = "#d3869b";
      aqua = "#8ec07c";
      orange = "#fe8019";
    };
  };

  # Modifier key for sway
  mod = "Mod4";
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
    # Uncomment as needed:
    # git-config = {
    #   file = "${secretsPath}/git-config.age";
    #   path = "${homeDir}/.config/git/config.local";
    # };
    # modal-config = {
    #   file = "${secretsPath}/modal.toml.age";
    #   path = "${homeDir}/.config/modal/modal.toml";
    # };
    # ngrok-config = {
    #   file = "${secretsPath}/ngrok.yml.age";
    #   path = "${homeDir}/.config/ngrok/ngrok.yml";
    # };
  };

  # Packages
  home.packages = with pkgs; [
    # 1Password CLI
    _1password-cli

    # Browser
    brave

    # Sway desktop (foot, mako, i3status via programs.* below)
    bemenu
    j4-dmenu-desktop
    swaylock
    swaybg
    wl-clipboard
    grim
    slurp
    brightnessctl

    # Terminal utilities (tmux, neovim, direnv via programs.* below)
    nodejs
    fd
    fzf
    ripgrep
    jq
    htop
    diff-so-fancy

    # Git signing
    gnupg

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
      FZF_DEFAULT_COMMAND = "fd --type f --hidden";
      GRIM_DEFAULT_DIR = "$HOME/screenshots";
      PNPM_HOME = "$HOME/.local/bin";
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
      # Run first: tmux auto-start
      (lib.mkBefore ''
        # Set terminal colors before running tmux
        if [[ -n $WAYLAND_DISPLAY ]] && [[ -z $TMUX ]] && [[ -z $NO_TMUX ]]; then
            if [[ -n "$PS1" ]] && [[ -f $HOME/.config/gruvbox.sh ]]; then
                source $HOME/.config/gruvbox.sh
            fi
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

  # Tmux
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      # Dvorak copy-mode navigation (d/h/t/n)
      bind-key -T copy-mode-vi d send-keys -X cursor-left
      bind-key -T copy-mode-vi h send-keys -X cursor-down
      bind-key -T copy-mode-vi t send-keys -X cursor-up
      bind-key -T copy-mode-vi n send-keys -X cursor-right

      # Clipboard (Wayland)
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key p run "wl-paste -n | tmux load-buffer - ; tmux paste-buffer"

      # Gruvbox colors
      set -g status-style bg=colour237,fg=colour223
      set -g message-style bg=colour239,fg=colour223
      set -g pane-border-style fg=colour239
      set -g pane-active-border-style fg=colour214
    '';
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
    "nvim/lua/lsp.lua".source = ./nvim/lua/lsp.lua;
    "nvim/UltiSnips/all.snippets".source = ./nvim/UltiSnips/all.snippets;
  };

  # Foot terminal
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "NotoSansM Nerd Font:size=14";
        dpi-aware = "yes";
      };
      colors = {
        background = lib.removePrefix "#" colors.bg;
        foreground = lib.removePrefix "#" colors.fg;
        regular0 = lib.removePrefix "#" colors.bg;
        regular1 = lib.removePrefix "#" colors.red;
        regular2 = lib.removePrefix "#" colors.green;
        regular3 = lib.removePrefix "#" colors.yellow;
        regular4 = lib.removePrefix "#" colors.blue;
        regular5 = lib.removePrefix "#" colors.purple;
        regular6 = lib.removePrefix "#" colors.aqua;
        regular7 = lib.removePrefix "#" colors.gray;
        bright0 = lib.removePrefix "#" colors.gray;
        bright1 = lib.removePrefix "#" colors.bright.red;
        bright2 = lib.removePrefix "#" colors.bright.green;
        bright3 = lib.removePrefix "#" colors.bright.yellow;
        bright4 = lib.removePrefix "#" colors.bright.blue;
        bright5 = lib.removePrefix "#" colors.bright.purple;
        bright6 = lib.removePrefix "#" colors.bright.aqua;
        bright7 = lib.removePrefix "#" colors.fg;
      };
    };
  };

  # i3status
  programs.i3status = {
    enable = true;
    general = {
      colors = true;
      color_good = colors.bright.green;
      color_degraded = colors.bright.yellow;
      color_bad = colors.bright.red;
      interval = 5;
    };
    modules = {
      "wireless _first_" = {
        position = 1;
        settings = {
          format_up = "W: %quality %essid %ip";
          format_down = "W: down";
        };
      };
      "battery 0" = {
        position = 2;
        settings = {
          format = "%status %percentage %remaining";
          format_down = "No battery";
          status_chr = "CHR";
          status_bat = "BAT";
          status_unk = "UNK";
          status_full = "FULL";
          low_threshold = 20;
        };
      };
      "load" = {
        position = 3;
        settings.format = "L: %1min";
      };
      "memory" = {
        position = 4;
        settings = {
          format = "M: %percentage_used";
          threshold_degraded = "10%";
          threshold_critical = "5%";
        };
      };
      "tztime local" = {
        position = 5;
        settings.format = "%Y-%m-%d %H:%M";
      };
    };
  };

  # Mako notifications
  services.mako = {
    enable = true;
    settings = {
      background-color = colors.bg;
      text-color = colors.fg;
      border-color = colors.blue;
      default-timeout = 5000;
    };
  };

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "foot";
      menu = "j4-dmenu-desktop --dmenu='bemenu -i' --term='foot'";

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_variant = "dvorak";
          xkb_options = "ctrl:swapcaps";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      output."*".bg = "${colors.bg} solid_color";

      bars = [{
        statusCommand = "i3status";
        colors = {
          background = colors.bg;
          statusline = colors.fg;
          separator = "#666666";
          focusedWorkspace = { background = colors.blue; border = colors.blue; text = colors.fg; };
          activeWorkspace = { background = colors.bg; border = colors.bg; text = colors.fg; };
          inactiveWorkspace = { background = colors.bg; border = colors.bg; text = colors.gray; };
          urgentWorkspace = { background = colors.red; border = colors.red; text = colors.fg; };
        };
      }];

      keybindings = let
        # Generate workspace keybindings
        workspaceBindings = lib.listToAttrs (lib.flatten (map (n: [
          { name = "${mod}+${toString n}"; value = "workspace number ${toString n}"; }
          { name = "${mod}+Shift+${toString n}"; value = "move container to workspace number ${toString n}"; }
        ]) (lib.range 1 9)));

        workspace10Bindings = {
          "${mod}+0" = "workspace number 10";
          "${mod}+Shift+0" = "move container to workspace number 10";
        };
      in workspaceBindings // workspace10Bindings // {
        "${mod}+Return" = "exec foot";
        "${mod}+Shift+q" = "kill";
        "${mod}+space" = "exec j4-dmenu-desktop --dmenu='bemenu -i' --term='foot'";

        # Dvorak focus (d/h/t/n)
        "${mod}+d" = "focus left";
        "${mod}+h" = "focus down";
        "${mod}+t" = "focus up";
        "${mod}+n" = "focus right";

        # Dvorak move
        "${mod}+Shift+d" = "move left";
        "${mod}+Shift+h" = "move down";
        "${mod}+Shift+t" = "move up";
        "${mod}+Shift+n" = "move right";

        # Layout
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+a" = "focus parent";

        # Brightness
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

        # Screenshots
        "${mod}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "${mod}+Shift+p" = "exec grim - | wl-copy";

        # Reload/exit
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec swaymsg exit";
      };
    };
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
