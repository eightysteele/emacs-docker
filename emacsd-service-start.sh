#!/usr/bin/env bash

source $HOME/.bashrc

exec /usr/local/bin/emacs --daemon -l $HOME/.config/emacs/init.el
