#!/usr/bin/env bash

git config --global --add safe.directory "*"

yes | emacs --debug-init --daemon

/bin/bash
