#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

# Source shared helpers (common.sh) relative to this script's directory.
DB_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
COMMON="$DB_DIR/../scripts/common.sh"

if [ -f "$COMMON" ]; then
    # shellcheck source=/dev/null
    . "$COMMON"
    # use DB_DIR to avoid being overwritten by sourced scripts
    . "$DB_DIR/relational/oracle/uninstall.sh"
    . "$DB_DIR/relational/mysql/uninstall.sh"
    . "$DB_DIR/relational/mssql/uninstall.sh"
    . "$DB_DIR/relational/postgresql/uninstall.sh"
else
    echo "Error: common.sh not found at $COMMON" >&2
    exit 1
fi
