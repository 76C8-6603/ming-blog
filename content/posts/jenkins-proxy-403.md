---

    title: "jenkins反向代理403 No valid crumb was included in the request"
    date: 2019-12-23
    tags: ["jenkins"]

---
# 异常信息
```
HTTP ERROR 403 No valid crumb was included in the request
```

# 解决方法
进入Jenkins配置 -> `Global Security Settings` -> `Enables the Compatibilty Mode for proxies`