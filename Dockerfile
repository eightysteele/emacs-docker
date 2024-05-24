# syntax=docker/dockerfile:1.7-labs
ARG EMACS_VERSION=29.3
ARG GO_VERSION=1.21.6
ARG NVM_VERSION=0.39.3
ARG NODE_VERSION=20.13.1
ARG XDG_HOME=/opt/xdg
ARG XDG_BIN_HOME=${XDG_HOME}/.local/bin
ARG XDG_CONFIG_HOME=${XDG_HOME}/.config
ARG XDG_DATA_HOME=${XDG_HOME}/.local/share
ARG XDG_CACHE_HOME=${XDG_HOME}/.cache
ARG NVM_DIR=${XDG_CONFIG_HOME}/nvm
ARG ORGMODE_REPO
ARG ORGMODE_TOKEN
ARG SPACEMACS_D_REPO

################################################################################
FROM ubuntu:jammy AS base
################################################################################

ARG EMACS_VERSION
ARG GO_VERSION
ARG NVM_VERSION
ARG NODE_VERSION
ARG XDG_HOME
ARG XDG_BIN_HOME
ARG XDG_CONFIG_HOME
ARG XDG_DATA_HOME
ARG XDG_CACHE_HOME
ARG NVM_DIR
ARG ORGMODE_REPO
ARG ORGMODE_TOKEN
ARG SPACEMACS_D_REPO
ENV DEBIAN_FRONTEND=noninteractive
RUN bash -x <<"EOF"
set -eu
rm -f /etc/apt/apt.conf.d/docker-clean
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    wget \
    gnupg \
    git \
    libncurses5-dev \
    libgnutls28-dev \
    libxml2-dev \
    xorg-dev \
    libgtk-3-dev \
    libharfbuzz-dev \
    libxaw7-dev \
    libxpm-dev \
    libpng-dev \
    zlib1g-dev \
    libjpeg-dev \
    libtiff-dev \
    libgif-dev \
    librsvg2-dev \
    libwebp-dev \
    imagemagick \
    libmagickwand-dev \
    libwebkit2gtk-4.0-dev \
    libgccjit-11-dev \
    libjansson-dev \
    fonts-firacode \
    curl \
    python3-pip \
    rsync
wget https://ftp.gnu.org/gnu/gnu-keyring.gpg
gpg --import gnu-keyring.gpg
EOF

# ------------------------------------------------------------------------------
# Setup XDG.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
mkdir -p \
    $XDG_HOME \
    $XDG_CONFIG_HOME \
    $XDG_DATA_HOME \
    $XDG_CACHE_HOME \
    $XDG_BIN_HOME
EOF
ENV PATH=${XDG_BIN_HOME}:$PATH

# #-------------------------------------------------------------------------------
# # Build emacs.
# #-------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
export TZ=America/Los_Angeles
dir=emacs-${EMACS_VERSION}
tar=${dir}.tar.gz
sig=${dir}.tar.gz.sig
taru=https://ftp.gnu.org/gnu/emacs/$tar
sigu=https://ftp.gnu.org/gnu/emacs/$sig
wget $taru
wget $sigu
if ! gpg --verify $sig $tar; then
    echo "gpg --verify failed"
	  exit 1
fi
tar xf $tar
pushd $dir
./configure \
    --with-xwidgets \
    --with-x \
    --with-x-toolkit=gtk3 \
    --with-imagemagick \
    --with-json \
    --with-native-compilation=yes \
    --with-mailutils
make -j$(nproc)
make install
popd
EOF

# ------------------------------------------------------------------------------
# Build Haskell toolchain.
# https://github.com/haskell/ghcup-hs/tree/master/scripts/bootstrap
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
export GHCUP_USE_XDG_DIRS=1
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_VERBOSE=1
export BOOTSTRAP_HASKELL_INSTALL_HLS=1
export BOOTSTRAP_HASKELL_ADJUST_BASHRC=1
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
cabal update
cabal install cabal-install
EOF

# ------------------------------------------------------------------------------
# Build shellcheck.
# https://github.com/koalaman/shellcheck
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
git clone https://github.com/koalaman/shellcheck.git
cd shellcheck
cabal install ShellCheck
rsync -Lr ~/.cabal ${XDG_CONFIG_HOME}/
rsync -Lr ${XDG_CONFIG_HOME}/.cabal/bin/* $XDG_BIN_HOME/
EOF

# ------------------------------------------------------------------------------
# Build nvm and node.
# https://github.com/nvm-sh/nvm
# ------------------------------------------------------------------------------
RUN bash -x <<"EOF"
set -eu
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
source ${NVM_DIR}/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
EOF

# ------------------------------------------------------------------------------
# Build dockerfile-language-server
# https://github.com/rcjsuen/dockerfile-language-server
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
source ${NVM_DIR}/nvm.sh
git clone https://github.com/rcjsuen/dockerfile-language-server.git
pushd dockerfile-language-server
npm install
npm audit fix
npm run build
npm test
npm install -g dockerfile-language-server-nodejs
popd
EOF

# ------------------------------------------------------------------------------
# Build hadolint. 
# https://github.com/hadolint/hadolint
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
git clone https://github.com/hadolint/hadolint
pushd hadolint
mv cabal.project.freeze cabal.project.freeze.backup
cabal update
cabal configure
cabal update
cabal build
cabal install
pushd dist-newstyle/build/x86_64-linux/ghc-9.4.8/hadolint-2.13.0/x/hadolint/build/
rsync -L hadolint/hadolint ${XDG_BIN_HOME}/
popd
popd
EOF

# ------------------------------------------------------------------------------
# Install Go.
# https://github.com/hadolint/hadolint
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C ${XDG_DATA_HOME} -xzf go${GO_VERSION}.linux-amd64.tar.gz
rsync -Lr ${XDG_DATA_HOME}/go/bin/* ${XDG_BIN_HOME}/
EOF
ENV GOROOT=${XDG_DATA_HOME}/go
ENV GOPATH=${XDG_DATA_HOME}/go

# ------------------------------------------------------------------------------
# Install shfmt
# https://github.com/mvdan/sh
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
go install mvdan.cc/sh/v3/cmd/shfmt@latest
rsync -L ${XDG_DATA_HOME}/go/bin/shfmt ${XDG_BIN_HOME}/
EOF

# ------------------------------------------------------------------------------
# Install bash-language-server
# https://github.com/bash-lsp/bash-language-server
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
source ${NVM_DIR}/nvm.sh
npm i -g bash-language-server
EOF

################################################################################
FROM ubuntu:jammy AS runtime
################################################################################

ARG XDG_HOME
ARG XDG_BIN_HOME
ARG XDG_CONFIG_HOME
ARG XDG_DATA_HOME
ARG XDG_CACHE_HOME
ARG ORGMODE_REPO
ARG ORGMODE_TOKEN
ARG SPACEMACS_D_REPO
ARG NVM_VERSION
ARG NODE_VERSION
ARG NVM_DIR
RUN bash -x <<"EOF"
set -eu
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    libxpm4 \
    libpng16-16 \
    libjpeg8 \
    libtiff5 \
    libgif7 \
    librsvg2-2 \
    libwebp7 \
    libgtk-3-0 \
    libgccjit0 \
    libjansson4 \
    libwebkit2gtk-4.0-37 \
    libmagickwand-6.q16-6 \
    libice6 \
    libsm6 \
    fonts-firacode \
    curl \
    git \
    wget
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

# ------------------------------------------------------------------------------
# Setup and authenticate GH CLI.
# https://github.com/cli/cli
# ------------------------------------------------------------------------------
RUN bash -x <<"EOF"
set -eu
mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update
apt install gh -y
echo $ORGMODE_TOKEN | gh auth login --with-token
git config --global user.name "Aaron Steele"
git config --global user.email "eightysteele@gmail.com"
EOF

COPY --from=base ${XDG_HOME} ${XDG_HOME}
COPY --from=base /usr/local /usr/local
COPY --from=base ${NVM_DIR} ${NVM_DIR}

# ------------------------------------------------------------------------------
# Setup XDG.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
mkdir -p \
$XDG_CONFIG_HOME \
$XDG_DATA_HOME \
$XDG_CACHE_HOME
EOF

# ------------------------------------------------------------------------------
# Clone spacemacs, spacemacs.d, and the org mode data repo.
# ------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
cd ${XDG_CONFIG_HOME}
export SPACEMACSDIR=${XDG_CONFIG_HOME}/spacemacs.d
git clone https://github.com/syl20bnr/spacemacs emacs
git clone "$SPACEMACS_D_REPO" spacemacs.d
if [[ -n $ORGMODE_TOKEN && -n $ORGMODE_REPO ]]; then
	  git clone https://${ORGMODE_TOKEN}@${ORGMODE_REPO}
fi
EOF

#-------------------------------------------------------------------------------
# Initialize spacemacs with first launch to compile packages.
# https://github.com/syl20bnr/spacemacs/tree/develop#default-install
#-------------------------------------------------------------------------------

RUN bash -x <<"EOF"
set -eu
export SPACEMACSDIR=${XDG_CONFIG_HOME}/spacemacs.d
EOF

#-------------------------------------------------------------------------------
# Setup runtime environment
#-------------------------------------------------------------------------------

ENV PATH=$PATH:${XDG_BIN_HOME}:${NVM_DIR}/versions/node/v${NODE_VERSION}/bin
ENV XDG_HOME=${XDG_HOME}
ENV XDG_BIN_HOME=${XDG_BIN_HOME}
ENV XDG_CONFIG_HOME=${XDG_CONFIG_HOME}
ENV XDG_DATA_HOME=${XDG_DATA_HOME}
ENV XDG_CACHE_HOME=${XDG_CACHE_HOME}
ENV SPACEMACSDIR=${XDG_CONFIG_HOME}/spacemacs.d

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

