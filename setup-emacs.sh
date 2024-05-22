#!/usr/bin/env bash

set -e

CONFIG_DIR=$HOME/.config

mkdir $CONFIG_DIR && cd $CONFIG_DIR

git clone https://${ORG_TOKEN}@${ORG_REPO}
