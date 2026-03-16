#!/bin/sh

set -e

# Source shared helpers (common.sh) relative to this script's directory.
THIS_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
COMMON_CAND1="$THIS_DIR/../../../scripts/common.sh"
COMMON_CAND2="$THIS_DIR/../../scripts/common.sh"
ENV_FILE="$THIS_DIR/.env"

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
    . "$ENV_FILE"
else
    echo "Error: common.sh not found for oracle installer." >&2
    exit 1
fi

deploy_oracle(){
    detect_runtime || exit 1

    if ${CONTAINER_RUNTIME:-docker} ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
        if ${CONTAINER_RUNTIME:-docker} ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
            echo "Container '$CONTAINER_NAME' is already deployed and running."
        else
            echo "Container '$CONTAINER_NAME' exists but is stopped. Starting..."
            ${CONTAINER_RUNTIME:-docker} start "$CONTAINER_NAME"
            echo "Container '$CONTAINER_NAME' started."
        fi
        return 0
    fi

    mkdir -p "$VOLUME_PATH"

    ${CONTAINER_RUNTIME:-docker} run -d \
        --name "$CONTAINER_NAME" \
        -p "${PORT}:1521" \
        -e ORACLE_PWD="$PASS" \
        -v "$VOLUME_NAME:$VOLUME_PATH" \
        --restart unless-stopped \
        "$IMAGE"

    echo "Container '$CONTAINER_NAME' deployed."
}

deploy_oracle