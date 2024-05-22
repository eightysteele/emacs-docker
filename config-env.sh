#!/usr/bin/env bash

set -e

cd /root

mkdir "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR"/systemd/user
mkdir "$CONFIG_DIR"/emacs
mv emacsd.service "$CONFIG_DIR"/systemd/user/
mv init.el "$CONFIG_DIR"/emacs/

export XDG_CONFIG_HOME="$CONFIG_DIR"
export XDG_DATA_HOME="/root/.local/share"
export XDG_CACHE_HOME="/root/.cache"
export SPACEMACSDIR="$XDG_CONFIG_HOME/spacemacs.d"

pf
