---

    title: "nginx常用命令"
    date: 2018-05-13
    tags: ["nginx"]

---

```shell
# 查看nginx配置文件位置
nginx -t

# reload配置文件
nginx -s reload

# 检测配置文件是否能够正常编译
nginx -t -c /etc/nginx/nginx.conf
```