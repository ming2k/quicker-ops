> The script will use standalone mode to validate domain validation, make sure your host 80 port is available.

```sh
./acme.sh --domain example.com --email your-email@example.com
```

It will install pem in `/etc/ssl/${DOMAIN}`.

