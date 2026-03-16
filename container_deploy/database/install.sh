#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

# Determine base directory (either provided by caller via BASE_DIR, or derive from $0)
DB_DIR="${BASE_DIR:-$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)}"
COMMON_CAND1="$DB_DIR/../scripts/common.sh"
COMMON_CAND2="$DB_DIR/scripts/common.sh"

if [ -f "$COMMON_CAND1" ]; then
    COMMON="$COMMON_CAND1"
elif [ -f "$COMMON_CAND2" ]; then
    COMMON="$COMMON_CAND2"
else
    COMMON=""
fi

if [ -n "$COMMON" ] && [ -f "$COMMON" ]; then
    # shellcheck source=/dev/null
    . "$COMMON"
    # Run relational installers as separate shells so each script can resolve its own $0
    sh "$DB_DIR/relational/oracle/install.sh" "$@"
    sh "$DB_DIR/relational/mysql/install.sh" "$@"
    sh "$DB_DIR/relational/mssql/install.sh" "$@"
    sh "$DB_DIR/relational/postgresql/install.sh" "$@"
else
    echo "Error: common.sh not found in expected locations: $COMMON_CAND1 or $COMMON_CAND2" >&2
    exit 1
fi
