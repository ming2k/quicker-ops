#!/bin/bash

# Get the script's directory
$(dirname "$(readlink -f "$0")")
PROJECT_ROOT="$(dirname $(dirname "$(readlink -f "$0")"))"
SCRIPT_DIR="$PROJECT_ROOT/scripts"
ASSETS_DIR="$PROJECT_ROOT/assets"
CONFIG_PATH="$ASSETS_DIR/xray_config/config.json"

echo "Generating XRay configuration..."
# Run the Python script to generate config
python3 "$SCRIPT_DIR/gen_xray_config.py" "$CONFIG_PATH"

# Check if the config was generated successfully
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