This docker demo will help you quick start a website demo with ssl.

1. get into `demo-in-docker-with-ssl`;

2. copy your certificates (e.g. `fullchain.pem`) to `ssl/fullchain.pem`''

3. copy your private key (e.g. `private.key`) to `ssl/privkey.pem`;

4. Update the `nginx.conf`. for example, change the `sever_name`;

4. run `docker compose up -d`.