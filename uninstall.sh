#!/bin/sh

set -e

# Top-level uninstaller: runs setup_linux_lib and container_deploy uninstallers
ROOT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

echo "Running container_deploy uninstaller..."
if [ -f "$ROOT_DIR/container_deploy/uninstall.sh" ]; then
  sh "$ROOT_DIR/container_deploy/uninstall.sh" "$@"
else
  echo "Warning: $ROOT_DIR/container_deploy/uninstall.sh not found; skipping." >&2
fi

echo "Running setup_linux_lib uninstaller..."
if [ -f "$ROOT_DIR/setup_linux_lib/uninstall.sh" ]; then
  sh "$ROOT_DIR/setup_linux_lib/uninstall.sh" "$@"
else
  echo "Warning: $ROOT_DIR/setup_linux_lib/uninstall.sh not found; skipping." >&2
fi

echo "Top-level uninstallation completed."