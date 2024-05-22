#!/usr/bin/env bash

set -e

load_user_env() {
	source ~/.bashrc
	export $(grep -v '^#' ~/.env | xargs)
}

update_user_env() {
	local name="$1"
	local value="$2"
	export "$name"="$value"
	echo "export $name=$value" >>~/.bashrc
	echo "$name=$value" >>~/.env
}

update_user_path() {
	local path="$1"
	export PATH="$path"
	echo "export PATH=$path" >>~/.bashrc
}

ensure_dir() {
	local dir="$1"
	if [ ! -d "$dir" ]; then
		mkdir -p "$dir"
	fi
}