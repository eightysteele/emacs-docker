#!/usr/bin/env bash

# This script creates a new user account and adds them to the sudeors list. It
# expects USERNAME, UID, and GID to be defined in the environment.
set -e

# Required enviroment
: "${USERNAME?'Error: USERNAME is not set'}"
: "${UID?'Error: UID is not set'}"
: "${GID?'Error: GID is not set'}"

# Create user with sudo access
groupadd -g $GID $USERNAME
useradd -m -u $UID -g $GID -s /bin/bash $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

USER_HOME=/home/$USERNAME
touch $USER_HOME/.env
chown $UID:$GID $USER_HOME/.env
