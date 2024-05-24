#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TAG=emacs-docker:dev
DOCKER_RMI=0
COMPOSE_UP=0
COMPOSE_EXEC=0
COMPOSE_EXEC_CMD=""
COMPOSE_STOP=0

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

compose_up() {
	docker compose up --build -d
}

compose_stop() {
	docker compose stop emacs
}

compose_exec() {
	if [[ "$COMPOSE_EXEC_CMD" == "" ]]; then
		docker compose exec emacs /usr/local/bin/entrypoint.sh
	else
		docker compose exec emacs "$COMPOSE_EXEC_CMD"
	fi
}

docker_rmi() {
	docker images -q | grep -v "$(docker images $TAG -q)" | xargs docker rmi -f
	docker images prune
}

interpret() {
	if [[ "$COMPOSE_UP" == "1" ]]; then
		compose_up
	elif [[ "$COMPOSE_STOP" == "1" ]]; then
		compose_stop
	elif [[ "$COMPOSE_EXEC" == "1" ]]; then
		compose_exec
	elif [[ "$DOCKER_RMI" == "1" ]]; then
		docker_rmi
	fi
}

parse() {
	args=$(getopt -o h --long up,stop,exec:,rmi -- "$@")
	if [[ $? -ne 0 ]]; then
		exit 1
	fi
	eval set -- "$args"
	while [ : ]; do
		case "$1" in
		--up)
			COMPOSE_UP=1
			shift 1
			;;
		--stop)
			COMPOSE_STOP=1
			shift 1
			;;
		--exec)
			COMPOSE_EXEC=1
			COMPOSE_EXEC_CMD="$2"
			shift 2
			;;
		--rmi)
			DOCKER_RMI=1
			shift 1
			;;
		--)
			shift
			break
			;;
		*)
			echo "UNKNOWN OPTION $1"
			usage 1
			;;
		esac
	done
}

main() {
	cd "$SCRIPT_DIR"
	if ! cd "$SCRIPT_DIR"; then
		echo "failed to change into the project root directory $SCRIPT_DIR"
		exit 1
	fi
	parse "$@"
	interpret "$@"
}

main "$@"
