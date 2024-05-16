#!/usr/bin/env bash

# This script:
#
# - Clones the Spacemacs repo
# - Clones the user supplied spacemacs.d repo
# - Launches Emacs which bootstraps Spacemacs
#
set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"
source "$PWD/.bashrc"
load_user_env

# Required enviroment
: "${SPACEMACS_D_REPO?"Error: SPACEMACS_REPO is not set"}"

# Clone spacemacs
# https://github.com/syl20bnr/spacemacs/tree/develop#default-install
git clone https://github.com/syl20bnr/spacemacs .emacs.d

# Setup environment
update_user_env XDG_CONFIG_HOME "$HOME/.config"
update_user_env XDG_CACHE_HOME "$HOME/.cache"
update_user_env XDG_DATA_HOME "$HOME/.local/share"
update_user_env SPACEMACSDIR "$HOME/.config/spacemacs.d"

# Clone user spacemacs.d
ensure_dir $XDG_CONFIG_HOME
pushd $XDG_CONFIG_HOME
git clone "$SPACEMACS_D_REPO" spacemacs.d
popd

# Initialize spacemacs (uses spacemacs.d/init.el and compiles packages)
yes | emacs --daemon
