#!/bin/bash

# Check if a parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a config suffix as a parameter."
    echo "Usage: $0 <config_suffix>"
    exit 1
fi

# Set the config suffix from the parameter
config_suffix="$1"

# delete the last container
docker rm -f xray

# Define paths
source_config="config/config.${config_suffix}.json"
target_config="config/config.json"

# Check if source config exists
if [ ! -f "$source_config" ]; then
    echo "Error: Config file $source_config does not exist."
    exit 1
fi

# Copy the config file
cp "$source_config" "$target_config"

# Run the Docker container
docker run -d -p 10443:10443 --name xray --restart=always \
    -v "$(pwd)/config/config.json:/etc/xray/config.json" \
    ghcr.io/xtls/xray-core

echo "Xray container started with config $source_config"
