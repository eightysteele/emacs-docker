#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"
source ~/.bashrc

load_user_env

emacs --daemon

emacsclient -nc

tail -f /dev/null
