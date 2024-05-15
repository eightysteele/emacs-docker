#!/usr/bin/env bash

source $HOME/.bashrc

exec emacs --daemon

until emacsclient -e "(message \"Emacs is ready\")" &> /dev/null; do
    sleep 1
done

emacsclient -nc

tail -f /dev/null
