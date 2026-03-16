#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Source shared helpers
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
COMMON="$THIS_DIR/../../../scripts/common.sh"
ENV_FILE="$THIS_DIR/.env"

if [ -f "$COMMON" ]; then
  # shellcheck source=/dev/null
  source "$COMMON"
  source "$ENV_FILE"
else
  echo "Error: common.sh not found at $COMMON" >&2
  exit 1
fi

uninstall_mssql(){
  detect_runtime || exit 1

  CONTAINER_NAME=${CONTAINER_NAME:-mssql-server}
  VOLUME_NAME=${VOLUME_NAME:-mssql_data}

  if $CONTAINER_RUNTIME ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
    if $CONTAINER_RUNTIME ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
      echo "Stopping container $CONTAINER_NAME..."
      $CONTAINER_RUNTIME stop "$CONTAINER_NAME"
    fi
    echo "Removing container $CONTAINER_NAME..."
    $CONTAINER_RUNTIME rm "$CONTAINER_NAME"
  else
    echo "Container $CONTAINER_NAME not found."
  fi

  if [ -n "${VOLUME_NAME:-}" ]; then
    if [[ "$VOLUME_NAME" == /* ]]; then
      echo "Volume '$VOLUME_NAME' appears to be a host path; not removing automatically." >&2
    else
      if $CONTAINER_RUNTIME volume ls --format '{{.Name}}' | grep -wq "$VOLUME_NAME"; then
        echo "Removing volume $VOLUME_NAME..."
        $CONTAINER_RUNTIME volume rm "$VOLUME_NAME"
      else
        echo "Volume $VOLUME_NAME not found (may be a bind-mount)."
      fi
    fi
  fi

  echo "Uninstall complete for $CONTAINER_NAME."
}

uninstall_mssql
