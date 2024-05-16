#!/usr/bin/env bash

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/user-env.sh"
source "$SCRIPTS_DIR/utils.sh"

if [[ -v ORG_TOKEN && -v ORG_REPO ]]; then
	ensure_dir $XDG_CONFIG_HOME
	pushd $XDG_CONFIG_HOME
	git clone https://${ORG_TOKEN}@${ORG_REPO}
	popd
fi
