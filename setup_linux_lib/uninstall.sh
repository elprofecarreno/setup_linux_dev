#!/bin/sh

# Script to uninstall development tools and common utilities installed by setup_dev_env.sh
# Works on Ubuntu/Debian, Fedora, and Arch-based distros

set -e  # Exit immediately if a command exits with a non-zero status

# LOAD CONFIGURATION (load .env from the script directory)
SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    . "$SCRIPT_DIR/.env"
else
    echo "Configuration file .env not found in $SCRIPT_DIR"
    exit 1
fi

# Create a version of GENERICS_LIB with commas replaced by spaces (do not modify .env)
GENERICS_LIB_SPACED=$(printf '%s' "$GENERICS_LIB" | tr ',' ' ')
UBUNTU_LIB_SPACED=$(printf '%s' "$UBUNTU_LIB" | tr ',' ' ')

# Function to validate that all required environment variables are set
validate_env() {
    if [ -z "$GENERICS_LIB" ] || [ -z "$UBUNTU_LIB" ] || [ -z "$FEDORA_LIB" ] || [ -z "$ARCH_LIB" ]; then
        echo "One or more required environment variables are missing. Please check your .env file."
        exit 1
    fi
}

# Function to detect the package manager and set the appropriate variable
validate_package_manager(){
    echo "Detecting package manager..."

    # Detect package manager
    if command -v apt >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
    elif command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER="pacman"
    else
        echo "No supported package manager detected (apt, dnf, pacman)."
        exit 1
    fi

    echo "Detected package manager: $PACKAGE_MANAGER"
}

remove_docker_alias() {
    if grep -q "alias docker='$CONTAINER_LIB'" ~/.bashrc 2>/dev/null; then
        echo "Removing alias for docker to $CONTAINER_LIB in ~/.bashrc..."
        sed -i "/alias docker='$CONTAINER_LIB'/d" ~/.bashrc || true
        echo "Alias removed. Please run '. ~/.bashrc' or restart your terminal to apply the changes."
        . ~/.bashrc || true
    else
        echo "Alias for docker to $CONTAINER_LIB does not exist in ~/.bashrc."
    fi
}

# Function to uninstall packages depending on distro
uninstall_packages() {
    case "$PACKAGE_MANAGER" in
        apt)
            echo "Removing $UBUNTU_LIB_SPACED, $GENERICS_LIB_SPACED, $CONTAINER_LIB..."
            sudo apt remove --purge -y $UBUNTU_LIB_SPACED $GENERICS_LIB_SPACED $CONTAINER_LIB
            echo "Autoremove unnecessary dependencies..."
            sudo apt autoremove -y
            ;;
        dnf)
            echo "Removing development tools group and additional packages..."
            sudo dnf groupremove -y "$FEDORA_LIB"
            sudo dnf remove -y $GENERICS_LIB_SPACED $CONTAINER_LIB
            ;;
        pacman)
            echo "Removing $ARCH_LIB, $GENERICS_LIB_SPACED, $CONTAINER_LIB..."
            sudo pacman -Rns --noconfirm $ARCH_LIB $GENERICS_LIB_SPACED $CONTAINER_LIB || true
            ;;
    esac
}

# Validate environment variables before proceeding with uninstallation
echo "Validating environment variables..."
validate_env

# Detect package manager before proceeding with uninstallation
echo "Validating package manager..."
validate_package_manager

# Execute the uninstall function
echo "Starting uninstallation of packages..."
uninstall_packages

# Remove alias for docker to podman
remove_docker_alias

echo "Uninstallation completed successfully!"