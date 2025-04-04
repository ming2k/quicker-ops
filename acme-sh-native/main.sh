#!/bin/bash

# Check if required arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 --domain <domain> --email <email>"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --email)
            EMAIL="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Validate domain and email
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Error: Domain and email are required"
    exit 1
fi

# Create temporary directory for initial setup
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Check if acme.sh is already installed
if [ -d "$HOME/.acme.sh" ]; then
    echo "ACME.sh is already installed. Updating..."
    cd "$HOME/.acme.sh"
    git pull
else
    # Download and install acme.sh into home directory
    git clone https://github.com/acmesh-official/acme.sh.git
    cd acme.sh
    ./acme.sh --install --home "$HOME/.acme.sh" --accountemail "$EMAIL"
fi

# Generate certificates using standalone mode
"$HOME/.acme.sh/acme.sh" --issue --standalone -d "$DOMAIN" --server letsencrypt --force

# Create target directory if it doesn't exist
sudo mkdir -p /etc/ssl/certs

# Move certificates to their final locations
# Updated paths to match the correct structure
sudo mv "$HOME/.acme.sh/${DOMAIN}_ecc/ca.cer" "/etc/ssl/certs/$DOMAIN.ca.cer"
sudo mv "$HOME/.acme.sh/${DOMAIN}_ecc/fullchain.cer" "/etc/ssl/certs/$DOMAIN.fullchain.cer"
sudo mv "$HOME/.acme.sh/${DOMAIN}_ecc/$DOMAIN.cer" "/etc/ssl/certs/$DOMAIN.cer"
sudo mv "$HOME/.acme.sh/${DOMAIN}_ecc/$DOMAIN.key" "/etc/ssl/certs/$DOMAIN.key"

# Set proper permissions
sudo chmod 644 "/etc/ssl/certs/$DOMAIN.ca.cer"
sudo chmod 644 "/etc/ssl/certs/$DOMAIN.fullchain.cer"
sudo chmod 644 "/etc/ssl/certs/$DOMAIN.cer"
sudo chmod 600 "/etc/ssl/certs/$DOMAIN.key"

# Cleanup temporary directory
cd /
rm -rf "$TEMP_DIR"

echo "Certificate generation completed successfully!"
echo "Certificates have been placed in /etc/ssl/certs/"
echo "ACME.sh has been installed in $HOME/.acme.sh"
