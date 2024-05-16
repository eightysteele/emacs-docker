#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(realpath "$(dirname "$SCRIPT_DIR")")
TAG=emacs-docker:dev

host_os() {
	local os=""

	os="$(uname -s)"

	case "$os" in
	Linux*)
		echo :linux
		return 0
		;;
	Darwin*)
		echo :macos
		return 0
		;;
	*)
		echo :unknown
		return 1
		;;
	esac
}

docker_build() {
	echo "CLI: Docker build"
	if ! docker build \
		--build-arg USERNAME=$USER \
		--build-arg UID=$(id -u) \
		--build-arg GID=$(id -g) \
		--build-arg ORG_TOKEN=$ORG_TOKEN \
		--build-arg ORG_REPO=$ORG_REPO \
		--build-arg SPACEMACS_D_REPO=$SPACEMACS_D_REPO \
		--tag "$TAG" \
		--file Dockerfile .; then
		echo "docker build failed"
		exit 1
	fi

}

docker_run() {
	echo "CLI: Docker run"
	if ! docker run \
		--shm-size=2g \
		--privileged \
		--gpus all \
		-e DISPLAY=$DISPLAY \
		-v "$REPO_DIR":$HOME/code/github \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-it \
		"$TAG"; then
		#/bin/bash; then
		echo "docker run failed"
		exit 1
	fi
}

usage() {
	echo "-b docker build, -r docker run, -h help"
	exit 0
}

entrypoint() {
	cd "$SCRIPT_DIR"
	if ! cd "$SCRIPT_DIR"; then
		echo "failed to change into the project root directory $SCRIPT_DIR"
		exit 1
	fi

	while getopts ":brh" opt; do
		case $opt in
		b)
			docker_build
			;;
		r)
			docker_run
			;;
		h)
			usage
			;;
		\?)
			echo "Unknown option :("
			exit 1
			;;
		esac
	done
}

entrypoint "$@"
