NOTE: The script uses standalone mode to validate domain validation, so **make sure your host 80 port is available**.

```sh
./main.sh --domain example.com --email your-email@example.com
```


`ca.cer` is moved as `/etc/ssl/certs/example.com.ca.cer`
`fullchain.cer` is moved as `/etc/ssl/certs/example.com.fullchain.cer`
`example.com.cer` is moved as `/etc/ssl/certs/example.com.cer`
`example.com.key` is moved as `/etc/ssl/certs/example.com.key`
