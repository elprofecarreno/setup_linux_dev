#!/bin/sh

set -e

# Return the absolute directory of a script path.
# Accepts an optional path argument; otherwise attempts to use $0 or ${BASH_SOURCE} when available.
get_script_dir() {
  src="${1:-${BASH_SOURCE:-$0}}"
  if command -v readlink >/dev/null 2>&1; then
    resolved="$(readlink -f "$src" 2>/dev/null || printf '%s' "$src")"
    printf '%s' "$(cd "$(dirname "$resolved")" >/dev/null 2>&1 && pwd)"
  else
    printf '%s' "$(cd "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  fi
}

# Load .env located in BASE_DIR if set, otherwise try ENV_FILE if provided.
load_env() {
  if [ -n "${BASE_DIR:-}" ] && [ -f "$BASE_DIR/.env" ]; then
    # shellcheck source=/dev/null
    . "$BASE_DIR/.env"
  elif [ -n "${ENV_FILE:-}" ] && [ -f "$ENV_FILE" ]; then
    # shellcheck source=/dev/null
    . "$ENV_FILE"
  else
    echo "Warning: .env not found in BASE_DIR or ENV_FILE; relying on environment variables." >&2
  fi
}

# Detect available container runtime and export CONTAINER_RUNTIME (podman|docker)
detect_runtime() {
  if [ -n "${CONTAINER_RUNTIME:-}" ]; then
    return 0
  fi
  if command -v podman >/dev/null 2>&1; then
    CONTAINER_RUNTIME=podman
  elif command -v docker >/dev/null 2>&1; then
    CONTAINER_RUNTIME=docker
  else
    echo "Error: neither podman nor docker found. Install one to continue." >&2
    return 1
  fi
  export CONTAINER_RUNTIME
}

# Helper: run a container using the detected runtime
run_container() {
  detect_runtime || return 1
  "$CONTAINER_RUNTIME" "$@"
}
