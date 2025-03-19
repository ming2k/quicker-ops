import json
import subprocess
import uuid
import os
import pathlib
from datetime import datetime
import sys

def run_xray_command(command):
    try:
        full_command = f"xray {command}"
        result = subprocess.run(full_command, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"Error running command: {full_command}")
            print(f"Error: {result.stderr}")
            return None
        return result.stdout.strip()
    except Exception as e:
        print(f"Exception running command: {e}")
        return None

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
    try:
        pathlib.Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"Ensured directory exists: {directory}")
    except Exception as e:
        print(f"Error creating directory {directory}: {e}")
        sys.exit(1)

def generate_config():
    print("Please choose how to generate UUID and privateKey:")
    print("1. Auto-generate")
    print("2. Manual input")
    choice = input("Please enter your choice (1 or 2): ")

    if choice == '1':
        client_id = run_xray_command("uuid")
        if not client_id:
            print("Failed to generate UUID. Using Python's uuid module instead.")
            client_id = str(uuid.uuid4())
            
        key_output = run_xray_command("x25519")
        if not key_output:
            print("Failed to generate x25519 keys. Please enter them manually.")
            private_key = input("Please enter privateKey: ")
            public_key = input("Please enter publicKey: ")
        else:
            private_key = extract_private_key(key_output)
            public_key = extract_public_key(key_output)
    elif choice == '2':
        client_id = input("Please enter client ID: ")
        private_key = input("Please enter privateKey: ")
        public_key = input("Please enter publicKey: ")
    else:
        print("Invalid option, using auto-generate.")
        client_id = str(uuid.uuid4())
        key_output = run_xray_command("x25519")
        if not key_output:
            print("Failed to generate x25519 keys. Using placeholder values.")
            private_key = "REPLACE_WITH_ACTUAL_PRIVATE_KEY"
            public_key = "REPLACE_WITH_ACTUAL_PUBLIC_KEY"
        else:
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

    # Get current timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Get assets directory (parent dir of current file's parent dir)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_dir = os.path.join(project_root, "assets")
    
    print(f"Script directory: {script_dir}")
    print(f"Project root: {project_root}")
    print(f"Assets directory: {assets_dir}")
    
    ensure_directory_exists(assets_dir)
    
    # Generate filename with timestamp
    filename = f"config_{timestamp}.json"
    config_path = os.path.join(assets_dir, filename)
    
    # Create symlink path
    symlink_path = os.path.join(assets_dir, "config.json")

    # Write the config file
    try:
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=4)
        print(f"Configuration file has been generated at: {config_path}")
    except Exception as e:
        print(f"Error writing config file: {e}")
        sys.exit(1)

    # Create or update symlink to latest config
    try:
        if os.path.exists(symlink_path):
            os.remove(symlink_path)
        os.symlink(config_path, symlink_path)
        print(f"Symlink created at: {symlink_path}")
    except Exception as e:
        print(f"Error creating symlink (non-critical): {e}")

    print(f"Client ID: {client_id}")
    print(f"Private Key: {private_key}")
    print(f"Public Key: {public_key}")

if __name__ == "__main__":
    generate_config()
