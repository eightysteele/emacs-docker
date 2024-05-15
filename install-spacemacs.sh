#!/usr/bin/env bash

set -e

CONFIG_DIR=$HOME/.config

git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d

git clone https://github.com/eightysteele/spacemacs.d.git $CONFIG_DIR/spacemacs.d

USER_ENV=(
    "export PATH=$HOME/bin:$PATH"
    "export PATH=$HOME/.cabal/bin:$PATH"
    "export XDG_CONFIG_HOME=$CONFIG_DIR"
    "export XDG_DATA_HOME=$HOME/.local/share"
    "export XDG_CACHE_HOME=$HOME/.cache"
    "export SPACEMACSDIR=$CONFIG_DIR/spacemacs.d"
)

for v in "${USER_ENV[@]}"; do
    eval "$v"
    echo "$v" >> ~/.bashrc
done

sudo apt-get install fonts-firacode

yes | emacs --daemon
