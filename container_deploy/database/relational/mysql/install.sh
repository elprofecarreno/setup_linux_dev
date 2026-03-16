#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Source shared helpers (common.sh) relative to this script's directory.
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

deploy_mysql(){
    detect_runtime || exit 1

    # If container exists, either report running or start it
    if "${CONTAINER_RUNTIME:-docker}" ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
        if "${CONTAINER_RUNTIME:-docker}" ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
            echo "Container '$CONTAINER_NAME' is already deployed and running."
        else
            echo "Container '$CONTAINER_NAME' exists but is stopped. Starting..."
            "${CONTAINER_RUNTIME:-docker}" start "$CONTAINER_NAME"
            echo "Container '$CONTAINER_NAME' started."
        fi
        return 0
    fi

    # Ensure volume path exists (useful if VOLUME_PATH is a host path)
    mkdir -p "$VOLUME_PATH"

    "${CONTAINER_RUNTIME:-docker}" run -d \
    --name "$CONTAINER_NAME" \
    -p "${PORT}:3306" \
    -e MYSQL_ROOT_PASSWORD="$PASS" \
    -e MYSQL_DATABASE="${MYSQL_DATABASE:-}" \
    -e MYSQL_USER="${MYSQL_USER:-}" \
    -e MYSQL_PASSWORD="${MYSQL_PASSWORD:-}" \
    -v "$VOLUME_NAME:$VOLUME_PATH" \
    --restart unless-stopped \
    "$IMAGE"

    echo "Container '$CONTAINER_NAME' deployed."
}

deploy_mysql