#! /bin/sh

clear
tmux send-keys 'ttyd tmux attach' C-m
tmux split-window -h 'ngrok http localhost:7681'
