#!/usr/bin/env bash

git config --global --add safe.directory "*"

if pgrep -af "^emacs.*--daemon$" >/dev/null; then
	echo "Emacs daemon is running."
else
	echo "Starting Emacs daemon."
	yes | emacs --debug-init --daemon
fi

omd="$XDG_CONFIG_HOME/org-roam-data"
omdv="$XDG_CONFIG_HOME/emacs/org-roam/"
if [ -d "$omd" ]; then
	echo "First run: moving $omd into $omdv volume"
	mv "$omd" "$omdv"
fi

/bin/bash

#exec "@"
