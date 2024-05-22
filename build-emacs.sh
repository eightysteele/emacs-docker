#!/usr/bin/env bash

set -e

# Optional environment
: "${EMACS_VERSION:=29.3}"

EMACS_WORKDIR=/opt/emacs
EMACS_SRC_DIR=emacs-$EMACS_VERSION
EMACS_SRC_TAR=$EMACS_SRC_DIR.tar.gz
EMACS_SRC_SIG=$EMACS_SRC_DIR.tar.gz.sig
EMACS_SRC_URL=https://ftp.gnu.org/gnu/emacs/$EMACS_SRC_TAR
EMACS_SRC_SIG_URL=https://ftp.gnu.org/gnu/emacs/$EMACS_SRC_SIG

mkdir $EMACS_WORKDIR && cd $EMACS_WORKDIR

# Verification
# apt-get update
# apt-get install -y \
# 	wget \
# 	gnupg \
# 	git

wget $EMACS_SRC_URL
wget $EMACS_SRC_SIG_URL
wget https://ftp.gnu.org/gnu/gnu-keyring.gpg

gpg --import gnu-keyring.gpg
if ! gpg --verify $EMACS_SRC_SIG $EMACS_SRC_TAR; then
	echo "gpg --verify failed"
	exit 1
fi

# Dependencies
# apt-get update
# apt-get install -y \
# 	build-essential \
# 	libncurses5-dev \
# 	libgnutls28-dev \
# 	libxml2-dev \
# 	xorg-dev \
# 	libgtk-3-dev \
# 	libharfbuzz-dev libxaw7-dev \
# 	libxpm-dev \
# 	libpng-dev \
# 	zlib1g-dev \
# 	libjpeg-dev \
# 	libtiff-dev \
# 	libgif-dev \
# 	librsvg2-dev \
# 	libwebp-dev \
# 	imagemagick \
# 	libmagickwand-dev \
# 	libwebkit2gtk-4.0-dev \
# 	libgccjit-11-dev \
# 	libjansson-dev \
# 	fonts-firacode \
# 	curl
# apt-get clean && rm -rf /var/lib/apt/lists/*

# Build
tar xf $EMACS_SRC_TAR
rm $EMACS_SRC_TAR
cd $EMACS_SRC_DIR
./configure \
	--with-xwidgets \
	--with-x \
	--with-x-toolkit=gtk3 \
	--with-imagemagick \
	--with-json \
	--with-native-compilation=yes \
	--with-mailutils
make
make install
