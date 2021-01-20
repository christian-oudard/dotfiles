# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Don't put duplicate lines in the history. See bash(1) for more options.
HISTCONTROL=ignoredups:ignorespace

# Append to the history file, don't overwrite it.
shopt -s histappend

# Use a larger history size.
export HISTSIZE=25000
export HISTFILESIZE=50000

export HISTIGNORE=" *"

# Suppress "bash is deprecated" warning on MacOS
export BASH_SILENCE_DEPRECATION_WARNING=1

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Make "less" more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set terminal colors.
# Symlink or copy the colorscheme to this path from the repo https://github.com/chriskempson/base16-shell
BASE16_SHELL=$HOME/.colorscheme.sh
if [[ -s $BASE16_SHELL ]]; then
    source $BASE16_SHELL
fi

# Import color codes.
if [ -f "$HOME/.colors.sh" ]; then
    source ~/.colors.sh
fi
CLEAR_EOL="\033[K"

# Set the prompt.
function prompt_command() {
    # If working on a python virtualenv, show it in the prompt.
    if [ -n "$VIRTUAL_ENV" ]; then
        local virtualenv="  ($(basename $VIRTUAL_ENV)) "
    else
        local virtualenv=""
    fi

    # If working on a node virtualenv, show it in the prompt.
    if [ -n "$NODE_VIRTUAL_ENV" ]; then
        local nodevirtualenv="  ($(basename $NODE_VIRTUAL_ENV)) "
    else
        local nodevirtualenv=""
    fi

    # If coming in via ssh, show it in the prompt.
    if [ -n "$SSH_CLIENT" ]; then
        local ssh="  (ssh)"
    else
        local ssh=""
    fi

    # Show current git branch in the prompt.
    function find_git_branch {
       local dir=. head
       until [ "$dir" -ef / ]; do
          if [ -f "$dir/.git/HEAD" ]; then
             head=$(< "$dir/.git/HEAD")
             if [[ $head == ref:\ refs/heads/* ]]; then
                git_branch="${head#*/*/}"
             elif [[ $head != '' ]]; then
                git_branch="detached"
             else
                git_branch="unknown"
             fi
             return
          fi
          dir="../$dir"
       done
       git_branch=''
    }
    function find_git_dirty {
        local st=$(git status --untracked-files=no --porcelain 2>/dev/null)
        if [[ $st == "" ]]; then
            git_dirty=''
        else
            git_dirty='*'
        fi
    }
    find_git_branch
    find_git_dirty
    if [ -n "$git_branch" ]; then
        local git="  ($git_branch$git_dirty) "
    else
        local git=""
    fi

    function prompt_left() {
        printf "\
$base01bg$base06\\\\u@\h$base05:$base0D\w/\
$base0E$git\
$base0B$virtualenv\
$base0F$nodevirtualenv\
$base0C$ssh\
$CLEAR_EOL$reset\
"
    }

    # Prompt line with dollar sign.
    # We have to escape color codes so readline can correctly determine line length.
    dollar="\[$base01bg$base0D\]\$\[$reset\]"

    # Assemble the prompt.
    local left=$(prompt_left)
    PS1="${left}\n${dollar} "

    # Write history after every command.
    history -a
}
PROMPT_COMMAND=prompt_command

# Color settings for ls.
if [ -x /usr/bin/dircolors ] && [ -f "$HOME/.dircolors" ]; then
    eval $(dircolors -b $HOME/.dircolors)
fi

# Enable git command line completion in bash.
if [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# Python startup script and encoding.
export PYTHONIOENCODING=utf8
export PYTHONSTARTUP=$HOME/.pythonrc

# don't allow Ctrl-S to stop terminal output
stty stop ''

# Set editor.
export EDITOR='nvim'

# Computer-specific settings.
if [ -f "$HOME/.bashrc_local" ]; then
    source "$HOME/.bashrc_local"
fi

# FZF fuzzy finder uses fdfind.
export FZF_DEFAULT_COMMAND='fdfind --type f'

# Vagrant dotfiles outside of main tree.
export VAGRANT_DOTFILE_PATH="$HOME/.vagrant_dotfiles"

# Go path.
export GOPATH=$HOME/go

# Activate virtualenvwrapper.
# if command -v virtualenvwrapper.sh >/dev/null; then
#     source $(command -v virtualenvwrapper.sh)
# fi

# Load rbenv.
# if command -v rbenv >/dev/null; then
#     eval "$(rbenv init -)"
# fi

# Load nvm.
# export NVM_DIR="$HOME/.nvm"
# if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
#     source /usr/local/opt/nvm/nvm.sh
# fi

## Executable search path ##
export PATH="\
$HOME/bin:\
$HOME/.bin:\
$HOME/.local/bin:\
$HOME/.cargo/bin:\
$HOME/.cabal/bin:\
$HOME/.ghcup/bin:\
$HOME/.rbenv/bin:\
$HOME/.rbenv/plugins/ruby-build/bin:\
$HOME/.node/bin:\
$HOME/.npm-global/bin:\
$GOPATH/bin:\
/usr/local/bin:\
/opt/local/:\
/opt/local/bin:\
/sbin:\
${PATH}:\
"

# Load pyenv (after path modification).
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Interactive move command.
# Adapted from https://gist.github.com/premek/6e70446cfc913d3c929d7cdbfe896fef
function mv() {
  if [ "$#" -ne 1 ] || [ ! -e "$1" ]; then
    command mv --interactive "$@"
    return
  fi
  read -ei "$1" newfilename
  command mv --interactive -v -- "$1" "$newfilename"
}


## Aliases ##

if [ -n "$(ls --version | grep GNU)" ] ; then
    alias ls='ls -p --color=auto'
else
    alias ls='ls -p'
fi
alias i='ls'
alias ll='ls -lGh'
alias la='ls -A'
alias lh='find -maxdepth 1 -name ".*" -not -name "." -printf "%f\n" | xargs ls -d --color=auto'
alias lr='ls -R'
alias lla='ls -lGA'
alias lld='ls -ld'
alias llh='lh -lG'
alias cp='cp --interactive'

# Keep environment variables for sudo.
alias sudo='sudo -E'

# Set maximum width of returned lines for ag.
alias ag='ag -W 300'

# Fix scrolling issue with tmux + irssi
alias irssi='TERM=screen-256color irssi'

# Use "g" to mean "git", with correct tab completion.
alias g='git'
complete -o default -o nospace -F _git g

# fd is called fdfind in ubuntu.
alias fd=fdfind

# Use nvim if available, but call it "vim".
if command -v nvim >/dev/null; then
    alias vim=nvim
fi

# Call python3 when we type python.
if command -v python3 >/dev/null; then
    alias python=python3
fi
if command -v pip3 >/dev/null; then
    alias pip=pip3
fi
if command -v pytest-3 >/dev/null; then
    alias pytest=pytest-3
fi

export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
