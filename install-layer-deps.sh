#!/usr/bin/env bash

set -e

mkdir $HOME/deps && cd $HOME/deps

# Cabal
sudo apt-get install -y ghc cabal-install
cabal update

# Shellcheck
git clone https://github.com/koalaman/shellcheck.git
cd shellcheck
cabal install
export PATH="$HOME/.cabal/bin:$PATH"
echo "PATH=$HOME/.cabal/bin:$PATH" >>$HOME/.bashrc

# Node
sudo apt-get install -y curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 20.13.1
nvm use 20.13.1
nvm alias default 20.13.1
echo "PATH=$HOME/.config/nvm/versions/node/v20.13.1/bin:$PATH" >>$HOME/.bashrc
export PATH=$HOME/.config/nvm/versions/node/v20.13.1/bin:$PATH

# Docker LSP server
git clone https://github.com/rcjsuen/dockerfile-language-server.git
cd dockerfile-language-server
npm install
npm audit fixg
npm run build
npm test
npm install -g dockerfile-language-server-nodejs

# GHCUP
yes | curl -sSL https://get-ghcup.haskell.org/ | sh
source /home/eighty/.ghcup/env
echo "source $HOME/.ghcup/env" ~/.bashrc >>source
ghcup install ghc latest

# Hadolint
git clone https://github.com/hadolint/hadolint
cd hadolint
mv cabal.project.freeze cabal.project.freeze.backup
cabal configure
cabal build
cabal install

# Python and PIP
sudo apt install -y python3-pip

# Go
wget https://golang.org/dl/go1.21.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >>~/.bashrc
echo "export PATH=$HOME/go/bin" >>~/.bashrc
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

# shfmt
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Bash LSP server
npm i -g bash-language-server
