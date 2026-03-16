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

deploy_mssql(){
  detect_runtime || exit 1

  if [ -z "${SA_PASSWORD}" ]; then
    echo "Error: SA_PASSWORD must be set (or provided in .env)" >&2
    exit 1
  fi

  # If container exists, either report running or start it
  if $CONTAINER_RUNTIME ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
    if $CONTAINER_RUNTIME ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
      echo "Container '$CONTAINER_NAME' is already deployed and running."
    else
      echo "Container '$CONTAINER_NAME' exists but is stopped. Starting..."
      $CONTAINER_RUNTIME start "$CONTAINER_NAME"
      echo "Container '$CONTAINER_NAME' started."
    fi
    return 0
  fi

  mkdir -p "$VOLUME_PATH"

  $CONTAINER_RUNTIME run -d \
    --name "$CONTAINER_NAME" \
    -p "${PORT}:1433" \
    -e ACCEPT_EULA=Y \
    -e SA_PASSWORD="$SA_PASSWORD" \
    -v "$VOLUME_NAME:$VOLUME_PATH" \
    --restart unless-stopped \
    "$IMAGE"

  echo "Container '$CONTAINER_NAME' deployed."
}

deploy_mssql
