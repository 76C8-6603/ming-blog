---

    title: "Docker容器内访问宿主机localhost"
    date: 2020-09-07
    tags: ["docker"]

---

### 1. 直接访问宿主机ip

### 2. Docker宿主机ip别名
`host.docker.internal`，该别名会被容器解析为宿主机IP

### 3. 修改容器默认网络配置
覆盖默认的 `--network bridge`桥接模式，改为`--network host`与宿主机共享网络（隔离级别低，安全性降低）