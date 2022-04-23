---

    title: "nginx Failed to read PID from file"
    date: 2022-04-19
    tags: ["nginx"]

---

```shell
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
systemctl daemon-reload
systemctl restart nginx
```

> [参考来源](https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864)