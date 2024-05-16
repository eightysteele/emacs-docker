#!/usr/bin/env bash

set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

git clone https://github.com/rcjsuen/dockerfile-language-server.git
cd dockerfile-language-server
npm install
npm audit fix
npm run build
npm test
npm install -g dockerfile-language-server-nodejs
