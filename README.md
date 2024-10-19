
## acme.sh

Prerequist

1. Make sure your host 80 port is not used

```sh
./acme.sh --domain example.com --email your-email@example.com
```

## Nginx Series

### Demo in Docker with SSL

1. get into `demo-in-docker-with-ssl`;

2. copy your certificates (e.g. `fullchain.pem`) to `ssl/fullchain.pem`''

3. copy your private key (e.g. `private.key`) to `ssl/privkey.pem`;

4. run `docker compose up -d`.

