#!/usr/bin/env bash

systemctl --user start emacsd.service
exec "$@"
