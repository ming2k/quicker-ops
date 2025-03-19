#!/bin/bash

# Get the script's directory
PROJECT_ROOT="$(dirname $(dirname "$(readlink -f "$0")"))"
SCRIPT_DIR="$PROJECT_ROOT/scripts"
ASSETS_DIR="$PROJECT_ROOT/assets"

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

echo "Stopping existing XRay container if it exists..."
docker stop xray 2>/dev/null
docker rm xray 2>/dev/null

echo "Starting XRay container..."
docker run -d \
    -p 10443:10443 \
    --name xray \
    --restart=always \
    -v "$CONFIG_PATH:/etc/xray/config.json" \
    ghcr.io/xtls/xray-core

if [ $? -eq 0 ]; then
    echo "XRay container started successfully!"
    echo "Container logs:"
    docker logs xray
else
    echo "Error: Failed to start XRay container"
    exit 1
fi