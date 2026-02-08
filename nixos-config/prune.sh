#!/usr/bin/env bash
GC="nix-collect-garbage --delete-older-than 7d"
$GC
sudo $GC
