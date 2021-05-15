---

    title: "git push 异常SSL_connect: SSL_ERROR_SYSCALL"
    date: 2020-09-15
    tags: ["git"]

---
# 完整异常
```log
OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to github.com:443
```

# 解决方案
如果挂着tz，需要设置一下代理
```shell
git config --global http.proxy "127.0.0.1:1080"
git config --global https.proxy "127.0.0.1:1080"
```
如果不想设置全局的话
```shell
git config http.proxy "127.0.0.1:1080"
git config https.proxy "127.0.0.1:1080"
```

关掉tz的话，需要取消代理
```shell
git config --global --unset http.proxy
git config --global --unset https.proxy
```
同样不想设置全局的话
```shell
git config --unset http.proxy
git config --unset https.proxy
```

上面的解决方案如果行不通建议重启，多尝试几次push👏