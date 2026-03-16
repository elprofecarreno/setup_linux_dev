#!/bin/sh

set -e

# Source shared helpers
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
  echo "Error: common.sh not found for oracle uninstaller." >&2
  exit 1
fi

uninstall_oracle(){
  detect_runtime || exit 1

  echo "Using runtime: $CONTAINER_RUNTIME"

  if [ -z "${CONTAINER_NAME:-}" ]; then
    echo "Error: CONTAINER_NAME not set in .env or environment." >&2
    exit 1
  fi

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

  echo "Uninstall complete for $CONTAINER_NAME."
}

uninstall_oracle
