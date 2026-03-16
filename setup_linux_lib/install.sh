#!/bin/bash

# Script to install development tools and common utilities on Ubuntu/Debian, Fedora, and Arch-based distros

set -e  # Exit immediately if a command exits with a non-zero status

# LOAD CONFIGURATION
source .env

# Function to validate that all required environment variables are set
validate_env() {
    if [[ -z "$GENERICS_LIB" || -z "$UBUNTU_LIB" || -z "$FEDORA_LIB" || -z "$ARCH_LIB" ]]; then
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

# Function to install packages depending on distro
install_packages() {
    case "$PACKAGE_MANAGER" in
        apt)
            echo "Updating repositories..."
            sudo apt update
            echo "Installing $UBUNTU_LIB, $GENERICS_LIB, $CONTAINER_LIB..."
            sudo apt install -y $UBUNTU_LIB $GENERICS_LIB $CONTAINER_LIB
            ;;
        dnf)
            echo "Installing development tools group and additional packages..."
            sudo dnf groupinstall -y "$FEDORA_LIB"
            sudo dnf install -y $GENERICS_LIB $CONTAINER_LIB
            ;;
        pacman)
            echo "Updating repositories..."
            sudo pacman -Sy
            echo "Installing $ARCH_LIB, $GENERICS_LIB, $CONTAINER_LIB..."
            sudo pacman -S --needed --noconfirm $ARCH_LIB $GENERICS_LIB $CONTAINER_LIB
            ;;
    esac
}

add_docker_alias() {
    if ! grep -q "alias docker='$CONTAINER_LIB'" ~/.bashrc; then
        echo "Adding alias for docker to $CONTAINER_LIB in ~/.bashrc..."
        echo "alias docker='$CONTAINER_LIB'" >> ~/.bashrc
        echo "Alias added. Please run 'source ~/.bashrc' or restart your terminal to apply the changes."
        source ~/.bashrc
    else
        echo "Alias for docker to $CONTAINER_LIB already exists in ~/.bashrc."
    fi
}

# Validate environment variables before proceeding with installation
echo "Validating environment variables..."
validate_env

# Detect package manager before proceeding with installation
echo "Validating package manager..."
validate_package_manager

# Execute the installation function
echo "Starting installation of packages..."
install_packages

# Add alias for docker to podman
add_docker_alias

echo "Installation completed successfully!"