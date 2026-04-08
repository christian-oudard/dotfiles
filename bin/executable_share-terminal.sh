#! /bin/sh

clear
tmux send-keys 'ttyd tmux attach' C-m
tmux split-window -h 'TERM=xterm-256color ngrok http localhost:7681'
