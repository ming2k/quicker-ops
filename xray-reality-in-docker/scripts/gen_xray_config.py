import json
import subprocess
import uuid
import os
import argparse
import pathlib

def run_docker_command(command):
    full_command = f"docker run --rm ghcr.io/xtls/xray-core {command}"
    result = subprocess.run(full_command, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def extract_private_key(output):
    try:
        return output.split("Private key: ")[1].split("\n")[0].strip()
    except:
        return output

def extract_public_key(output):
    try:
        return output.split("Public key: ")[1].strip()
    except:
        return output

def ensure_directory_exists(directory):
    """Create directory if it doesn't exist"""
    pathlib.Path(directory).mkdir(parents=True, exist_ok=True)

def generate_config(output_path):
    print("Please choose how to generate UUID and privateKey:")
    print("1. Auto-generate")
    print("2. Manual input")
    choice = input("Please enter your choice (1 or 2): ")

    if choice == '1':
        client_id = run_docker_command("uuid")
        key_output = run_docker_command("x25519")
        private_key = extract_private_key(key_output)
        public_key = extract_public_key(key_output)
    elif choice == '2':
        client_id = input("Please enter client ID: ")
        private_key = input("Please enter privateKey: ")
        public_key = input("Please enter publicKey: ")
    else:
        print("Invalid option, using auto-generate.")
        client_id = str(uuid.uuid4())
        key_output = run_docker_command("x25519")
        private_key = extract_private_key(key_output)
        public_key = extract_public_key(key_output)

    config = {
        "inbounds": [
            {
                "listen": "0.0.0.0",
                "port": 10443,
                "protocol": "vless",
                "settings": {
                    "clients": [
                        {
                            "id": client_id,
                            "flow": "xtls-rprx-vision"
                        }
                    ],
                    "decryption": "none"
                },
                "streamSettings": {
                    "network": "tcp",
                    "security": "reality",
                    "realitySettings": {
                        "show": True,
                        "dest": "www.microsoft.com:443",
                        "xver": 0,
                        "serverNames": [
                            "www.microsoft.com"
                        ],
                        "privateKey": private_key,
                        "shortIds": [
                            ""
                        ]
                    }
                },
                "sniffing": {
                    "enabled": True,
                    "destOverride": [
                        "http",
                        "tls",
                        "quic"
                    ]
                }
            }
        ],
        "outbounds": [
            {
                "protocol": "freedom",
                "tag": "direct"
            }
        ]
    }

    # Ensure the output directory exists
    output_dir = os.path.dirname(output_path)
    if output_dir:
        ensure_directory_exists(output_dir)

    # Write the config file
    with open(output_path, 'w') as f:
        json.dump(config, f, indent=4)

    print(f"Configuration file has been generated at: {output_path}")
    print(f"Client ID: {client_id}")
    print(f"Private Key: {private_key}")
    print(f"Public Key: {public_key}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate XRay configuration file')
    parser.add_argument('output_path', help='Path where to save the config.json file')
    
    args = parser.parse_args()
    generate_config(args.output_path)