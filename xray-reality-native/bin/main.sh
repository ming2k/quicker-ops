#!/bin/bash

# Get the script's directory
PROJECT_ROOT="$(dirname $(dirname "$(readlink -f "$0")"))"
SCRIPT_DIR="$PROJECT_ROOT/scripts"
ASSETS_DIR="$PROJECT_ROOT/assets"

# Handle Xray commands based on parameter
case "$1" in
    "update")
        # Update Xray
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ update
        ;;
    "remove")
        # Remove Xray
        bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
        ;;
    *)
        # Install Xray if not already installed
        if ! command -v xray &> /dev/null; then
            echo "Installing Xray..."
            bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
        fi

        # List available config files and let user choose
        echo "Available config files:"
        configs=($(ls "$ASSETS_DIR"/config*.json))
        if [ ${#configs[@]} -eq 0 ]; then
            echo "No config files found. Generating new configuration..."
            python3 "$SCRIPT_DIR/gen_xray_config.py"
            configs=($(ls "$ASSETS_DIR"/config*.json))
        fi

        PS3="Select a config file to use: "
        select CONFIG_PATH in "${configs[@]}"; do
            if [ -n "$CONFIG_PATH" ]; then
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done

        echo "Using config file: $CONFIG_PATH"

        # Check if the config exists
        if [ ! -f "$CONFIG_PATH" ]; then
            echo "Error: Configuration file not found at $CONFIG_PATH"
            exit 1
        fi

        echo "Stopping existing XRay service if it exists..."
        systemctl stop xray 2>/dev/null

        echo "Starting XRay service..."
        cp "$CONFIG_PATH" /usr/local/etc/xray/config.json
        systemctl start xray

        if [ $? -eq 0 ]; then
            echo "XRay service started successfully!"
            echo "Service logs:"
            journalctl -u xray --no-pager -n 20
        else
            echo "Error: Failed to start XRay service"
            exit 1
        fi
        ;;
esac
