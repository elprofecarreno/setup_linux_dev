#!/usr/bin/env bash

set -euo pipefail

# Return the absolute directory of the currently-executing script file.
# Works when the file is executed or when it is sourced.
get_script_dir() {
  local src
  # If common.sh is sourced, BASH_SOURCE[1] refers to the caller script.
  # If it's executed directly, fall back to BASH_SOURCE[0] or $0.
  if [ "${#BASH_SOURCE[@]}" -gt 1 ] && [ -n "${BASH_SOURCE[1]:-}" ]; then
    src="${BASH_SOURCE[1]}"
  else
    src="${BASH_SOURCE[0]:-$0}"
  fi
  # resolve symlink if possible
  if command -v readlink >/dev/null 2>&1; then
    local resolved
    resolved="$(readlink -f "$src" 2>/dev/null || printf '%s' "$src")"
    printf '%s' "$(cd "$(dirname "$resolved")" >/dev/null 2>&1 && pwd)"
  else
    printf '%s' "$(cd "$(dirname "$src")" >/dev/null 2>&1 && pwd)"
  fi
}

# Load .env located in BASE_DIR or in the script directory if BASE_DIR not set.
load_env() {
  local script_dir
  script_dir="$(get_script_dir)"
  BASE_DIR="${BASE_DIR:-$script_dir}"
  if [ -f "$BASE_DIR/.env" ]; then
    # shellcheck source=/dev/null
    source "$BASE_DIR/.env"
  else
    echo "Warning: $BASE_DIR/.env not found; relying on environment variables." >&2
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

# Helper: run a container using the detected runtime (preserves common flags)
run_container() {
  detect_runtime || return 1
  # first arg is the runtime command to use (run/start/rm/etc)
  local cmd="$CONTAINER_RUNTIME"
  "$cmd" "$@"
}
