#!/usr/bin/env bash

set -e

groupadd -g $GID $USERNAME
useradd -m -u $UID -g $GID -s /bin/bash $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

mkdir /home/$USERNAME/bin
chown $UID:$GID /home/$USERNAME/bin
