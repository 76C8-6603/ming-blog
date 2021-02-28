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
```shell
git config --global --unset http.proxy
```
上面的解决方案如果行不通建议重启，多尝试几次push👏