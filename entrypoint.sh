#!/usr/bin/env bash

git config --global --add safe.directory "*"

exec emacs --debug-init --daemon &

exec emacsclient -nc &

exec /bin/bash
