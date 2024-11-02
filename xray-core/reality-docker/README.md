# Docker Deploy of Xray Core in REALITY 

This project is designed to be **straightforward** and does not support extensive custom configurations. The intention is to provide a simple solution that works well for my personal needs, allowing for quick deployment of configurations on a single, uncomplicated host.

Use [REALITY](https://github.com/XTLS/REALITY) in docker container solution.

## Prerequisites

Before running the scripts, ensure you have the following installed:

- Docker
- Bash
- Python3
- `readlink` command (available in most Linux distributions)

## Usage

1. Run the Bash script:
    ```bash
    bash bin/main.sh
    ```
2. Configuration Generation (Optional):
    The script includes a Python script (gen_xray_config.py) to generate a configuration file if needed. It will prompt you for options, including whether to auto-generate or manually input the UUID and private key.

## Notes

*Those message may help you*

You can generate UUID by

```sh
xray uuid
```

You can generate `privateKey` and `pubKey` by the following command:

```sh
xray x25519
```


## License

This project is licensed under the MIT License 