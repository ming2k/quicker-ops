#!/bin/bash
# Initialize variables
DOMAIN=""
EMAIL=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --domain) DOMAIN="$2"; shift ;;
        --email) EMAIL="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if necessary parameters are provided
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 --domain example.com --email your-email@example.com"
    exit 1
fi

# Create directories for certificates and acme.sh data
CERT_DIR="/etc/ssl/${DOMAIN}"
mkdir -p "$CERT_DIR"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Pull the latest acme.sh image
docker pull neilpang/acme.sh

# Register account and generate certificate
echo "Generating certificate for $DOMAIN..."
docker run --rm \
    -v "$CERT_DIR:/acme.sh/$DOMAIN" \
    -e "DOMAIN=$DOMAIN" \
    -e "EMAIL=$EMAIL" \
    --net=host \
    neilpang/acme.sh \
    --issue \
    --standalone \
    -d "$DOMAIN" \
    --server letsencrypt

# Check if certificate generation was successful
if [ $? -eq 0 ]; then
    echo "Certificate generated successfully!"
    
    # Install certificate using Docker
    echo "Installing certificate..."
    docker run --rm \
        -v "$CERT_DIR:/acme.sh/$DOMAIN" \
        -e "DOMAIN=$DOMAIN" \
        neilpang/acme.sh \
        --install-cert \
        -d "$DOMAIN" \
        --key-file "/acme.sh/$DOMAIN/private.key" \
        --fullchain-file "/acme.sh/$DOMAIN/fullchain.pem"
    
    if [ $? -eq 0 ]; then
        echo "Certificate installed successfully!"
        # Set appropriate permissions
        chmod 644 "$CERT_DIR/fullchain.pem"
        chmod 600 "$CERT_DIR/private.key"
    else
        echo "Certificate installation failed."
        exit 1
    fi
else
    echo "Certificate generation failed."
    exit 1
fi

# Display certificate information
docker run --rm \
    -v "$CERT_DIR:/acme.sh/$DOMAIN" \
    neilpang/acme.sh \
    --info \
    -d "$DOMAIN"

echo "Script execution completed."
