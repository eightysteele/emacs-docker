#!/usr/bin/env bash

git config --global --add safe.directory "*"

if pgrep -af "^emacs.*--daemon$" >/dev/null; then
	echo "emacs daemon is running."
else
	echo "starting emacs daemon..."
	yes | emacs --debug-init --daemon
fi

omd="$XDG_CONFIG_HOME/org-roam-data"
omdv="$XDG_CONFIG_HOME/emacs/org-roam/"
if [ -d "$omd" ]; then
	echo "first run, moving $omd into the $omdv volume"
	if [ -d "$omdv/org-roam-data" ]; then
		pushd "$omdv/org-roam-data" || exit 1
		git pull
		git add .
		git commit -m 'auto commit'
		if ! git push origin; then
			echo "unable to git push org-roam-data"
			exit 1
		fi
		popd || exit 1
	fi
	pushd "$omd" || exit 1
	if ! git pull; then
		echo "unable to git pull org-roam-data"
		exit 1
	fi
	popd || exit 1
	rm -rf "$omdv/org-roam-data"
	mv "$omd" "$omdv"
fi

/bin/bash
