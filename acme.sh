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

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script requires root privileges" 1>&2
   exit 1
fi

# Check and install socat
if ! command -v socat &> /dev/null
then
    echo "socat is not installed. Installing..."
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu systems
        apt-get update
        apt-get install -y socat
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL systems
        yum install -y socat
    else
        echo "Unable to determine system type. Please install socat manually."
        exit 1
    fi
fi

# Check if acme.sh is installed
if [ -f "$HOME/.acme.sh/acme.sh" ]; then
    ACME_CMD="$HOME/.acme.sh/acme.sh"
else
    echo "acme.sh is not installed. Installing..."
    curl https://get.acme.sh | sh -s email=$EMAIL
    source "$HOME/.acme.sh/acme.sh.env"
    ACME_CMD="$HOME/.acme.sh/acme.sh"
fi

# Register account
echo "Registering acme.sh account..."
$ACME_CMD --register-account -m $EMAIL

# Stop services that might be using port 80 (if any)
# For example: service nginx stop

# Generate certificate
echo "Generating certificate for $DOMAIN..."
$ACME_CMD --issue --force -d $DOMAIN --standalone

# Check if certificate generation was successful
if [ $? -eq 0 ]; then
    echo "Certificate generated successfully!"

    # Create directory for certificates
    CERT_DIR="/etc/ssl/${DOMAIN}"
    mkdir -p "$CERT_DIR"

    # Install certificate
    echo "Installing certificate..."
    $ACME_CMD --install-cert -d $DOMAIN \
        --key-file       "${CERT_DIR}/private.key"  \
        --fullchain-file "${CERT_DIR}/fullchain.pem"

    if [ $? -eq 0 ]; then
        echo "Certificate installed successfully!"
    else
        echo "Certificate installation failed."
    fi
else
    echo "Certificate generation failed."
fi

# Display certificate information
$ACME_CMD --info -d $DOMAIN

# Restart previously stopped services (if any)
# For example: service nginx start

echo "Script execution completed."

