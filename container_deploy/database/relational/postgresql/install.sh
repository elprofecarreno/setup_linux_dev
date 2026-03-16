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

deploy_postgresql(){
  detect_runtime || exit 1

  if [ -z "${POSTGRES_PASSWORD}" ]; then
    echo "Error: POSTGRES_PASSWORD must be set (or provided in .env)" >&2
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
    -p "${PORT}:5432" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -v "$VOLUME_NAME:$VOLUME_PATH" \
    --restart unless-stopped \
    "$IMAGE"

  echo "Container '$CONTAINER_NAME' deployed."
}

deploy_postgresql
