#! /bin/sh

tmux split-window -h -l 66% 'zsh -c "nvim; exec zsh"'
tmux select-pane -t 0
clear
