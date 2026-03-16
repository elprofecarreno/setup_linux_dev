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
  echo "Error: common.sh not found for postgresql installer." >&2
  exit 1
fi

deploy_postgresql(){
  detect_runtime || exit 1

  if [ -z "${POSTGRES_PASSWORD}" ]; then
    echo "Error: POSTGRES_PASSWORD must be set (or provided in .env)" >&2
    exit 1
  fi

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
