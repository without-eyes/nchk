#!/bin/bash

#!/usr/bin/env bash
set -e

# Detect and install curl based on the available package manager
if ! command -v curl &> /dev/null; then
    echo "curl is missing. Attempting installation..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y curl
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm curl
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y curl
    else
        echo "Error: Unsupported package manager. Please install curl manually." >&2
        exit 1
    fi
else
    echo "curl is already installed."
fi

# Move and configure the script globally
if [ -f "nchk.sh" ]; then
    echo "Installing nchk to /usr/local/bin/nchk..."
    sudo cp nchk.sh /usr/local/bin/nchk
    sudo chmod +x /usr/local/bin/nchk
    echo "Installation complete."
else
    echo "Error: nchk.sh not found in the current directory[cite: 1]." >&2
    exit 1
fi