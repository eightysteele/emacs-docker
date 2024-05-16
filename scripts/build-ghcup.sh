#!/usr/bin/env bash

yes | curl -sSL https://get-ghcup.haskell.org/ | sh
source /home/eighty/.ghcup/env
echo "source $HOME/.ghcup/env" ~/.bashrc >>source
ghcup install ghc latest
