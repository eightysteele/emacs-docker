#!/usr/bin/env bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/utils.sh"

git clone https://github.com/koalaman/shellcheck.git
cd shellcheck
cabal update && cabal install
