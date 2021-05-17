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
挂tz，需要设置一下代理
```shell
git config --global http.proxy "socks5://127.0.0.1:1080"
git config --global https.proxy "socks5://127.0.0.1:1080"
```
如果不想设置全局的话删掉`--global`即可  
注意上面的ip和端口号，要参考代理软件的socket配置，比如shadow**** 可以在`偏好设置->高级`中找到

关掉tz的话，需要取消代理（能不能连上就靠运气了🐶）
```shell
git config --global --unset http.proxy
git config --global --unset https.proxy
```
同样不想设置全局的话，删掉`--global`即可
上面的解决方案如果行不通建议重启，多尝试几次push👏