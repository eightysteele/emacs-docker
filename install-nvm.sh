#!/usr/bin/env bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

# Optional environment
: "${NVM_VERSION:=0.39.3}"
: "${NODE_VERSION:=20.13.1}"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
update_user_path ~/.config/nvm/versions/node/v$NODE_VERSION/bin:$PATH
bash --rcfile ~/.bashrc -i <<"EOF"
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
EOF
