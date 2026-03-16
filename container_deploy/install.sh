#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

# Compute script directory in a POSIX-compatible way
SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
if [ -f "$SCRIPT_DIR/database/install.sh" ]; then
	# shellcheck source=/dev/null
	. "$SCRIPT_DIR/database/install.sh"
else
	echo "Error: $SCRIPT_DIR/database/install.sh not found." >&2
	exit 1
fi

deploy_database