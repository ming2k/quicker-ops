# XRay Reality Native

A simple setup for XRay with Reality protocol.

## Prerequisites

- Linux system with systemd
- Python 3
- Bash

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/xray-reality-native.git
   cd xray-reality-native
   ```

2. Make the main script executable:
   ```
   chmod +x bin/main.sh
   ```

3. Run the script:
   ```
   sudo ./bin/main.sh
   ```

   This will:
   - Install XRay if not already installed
   - Generate a configuration file if none exists
   - Start the XRay service

## Commands

- Install/Start XRay:
  ```
  sudo ./bin/main.sh
  ```

- Update XRay:
  ```
  sudo ./bin/main.sh update
  ```

- Remove XRay:
  ```
  sudo ./bin/main.sh remove
  ```

## Configuration

Configuration files are stored in the `assets` directory. When you run the script for the first time, it will generate a new configuration file with a timestamp.

You can also manually create configuration files in the `assets` directory with the naming pattern `config*.json`.

## Troubleshooting

- Check XRay service status:
  ```
  sudo systemctl status xray
  ```

- View XRay logs:
  ```
  sudo journalctl -u xray -f
  ``` 