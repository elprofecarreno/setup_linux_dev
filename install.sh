#!/bin/sh

set -e

# Top-level installer: runs setup_linux_lib and container_deploy installers
ROOT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

echo "Running setup_linux_lib installer..."
if [ -f "$ROOT_DIR/setup_linux_lib/install.sh" ]; then
  sh "$ROOT_DIR/setup_linux_lib/install.sh" "$@"
else
  echo "Error: $ROOT_DIR/setup_linux_lib/install.sh not found." >&2
  exit 1
fi

echo "Running container_deploy installer..."
if [ -f "$ROOT_DIR/container_deploy/install.sh" ]; then
  sh "$ROOT_DIR/container_deploy/install.sh" "$@"
else
  echo "Error: $ROOT_DIR/container_deploy/install.sh not found." >&2
  exit 1
fi

echo "Top-level installation completed."