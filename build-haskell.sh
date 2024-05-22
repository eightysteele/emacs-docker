#!/usr/bin/env bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

load_user_env

# https://github.com/haskell/ghcup-hs/blob/master/scripts/bootstrap/bootstrap-haskell
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export GHCUP_USE_XDG_DIRS=1
export BOOTSTRAP_HASKELL_VERBOSE=1
export BOOTSTRAP_HASKELL_INSTALL_HLS=1
export BOOTSTRAP_HASKELL_ADJUST_BASHRC=1

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

update_user_path ~/.local/bin:$PATH
update_user_path ~/.cabal/bin:$PATH
