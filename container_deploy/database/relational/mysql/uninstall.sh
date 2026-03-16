#!/bin/sh

set -e

# Source shared helpers
THIS_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
COMMON="$THIS_DIR/../../../scripts/common.sh"
ENV_FILE="$THIS_DIR/.env"

if [ -f "$COMMON" ]; then
    # shellcheck source=/dev/null
    . "$COMMON"
    . "$ENV_FILE"
else
    echo "Error: common.sh not found at $COMMON" >&2
    exit 1
fi

uninstall_mysql(){
    detect_runtime || exit 1

    echo "Using runtime: $CONTAINER_RUNTIME"

    if [ -z "${CONTAINER_NAME:-}" ]; then
        echo "Error: CONTAINER_NAME not set in .env or environment." >&2
        exit 1
    fi

    # Remove container if exists
    if ${CONTAINER_RUNTIME:-docker} ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
        if ${CONTAINER_RUNTIME:-docker} ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
            echo "Stopping container $CONTAINER_NAME..."
            ${CONTAINER_RUNTIME:-docker} stop "$CONTAINER_NAME"
        fi
        echo "Removing container $CONTAINER_NAME..."
        ${CONTAINER_RUNTIME:-docker} rm "$CONTAINER_NAME"
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    # Remove named volume if applicable
    if [ -n "${VOLUME_NAME:-}" ]; then
        case "$VOLUME_NAME" in
            /*)
                echo "Volume '$VOLUME_NAME' appears to be a host path; not removing automatically." >&2
                ;;
            *)
                if ${CONTAINER_RUNTIME:-docker} volume ls --format '{{.Name}}' | grep -wq "$VOLUME_NAME"; then
                    echo "Removing volume $VOLUME_NAME..."
                    ${CONTAINER_RUNTIME:-docker} volume rm "$VOLUME_NAME"
                else
                    echo "Volume $VOLUME_NAME not found (may be a bind-mount)."
                fi
                ;;
        esac
    fi

    # Optionally remove the image used by this deployment
    if [ -n "${IMAGE:-}" ]; then
        if ${CONTAINER_RUNTIME:-docker} image inspect "$IMAGE" >/dev/null 2>&1; then
            echo "Removing image $IMAGE..."
            ${CONTAINER_RUNTIME:-docker} image rm "$IMAGE" || true
        else
            echo "Image $IMAGE not found; skipping image removal." >&2
        fi
    fi

    echo "Uninstall complete for $CONTAINER_NAME."
}

uninstall_mysql