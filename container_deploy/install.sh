#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# If executed with `sh install.sh` re-exec with bash to ensure bash features work
if [ -z "${BASH_VERSION:-}" ]; then
	if command -v bash >/dev/null 2>&1; then
		exec bash "$0" "$@"
	else
		echo "This script requires bash. Install bash or run the script with bash." >&2
		exit 1
	fi
fi

# Load database installer from this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [ -f "$SCRIPT_DIR/database/install.sh" ]; then
	# shellcheck source=/dev/null
	source "$SCRIPT_DIR/database/install.sh"
else
	echo "Error: $SCRIPT_DIR/database/install.sh not found." >&2
	exit 1
fi

deploy_database