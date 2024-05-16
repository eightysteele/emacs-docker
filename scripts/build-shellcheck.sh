#!/usr/bin/env bash

set -e

git clone https://github.com/koalaman/shellcheck.git
cd shellcheck
cabal update && cabal install
