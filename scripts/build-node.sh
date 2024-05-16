#!/usr/bin/env bash

set -e

# Optional environment
: "${NVM_VERSION:=0.39.3}"
: "${NODE_VERSION:=20.13.1}"

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
echo "PATH=$HOME/.config/nvm/versions/node/v$NODE_VERSION/bin:$PATH" >>$HOME/.bashrc
export PATH=$HOME/.config/nvm/versions/node/v$NODE_VERSION/bin:$PATH
