---

    title: "Docker Registry"
    date: 2019-09-22
    tags: ["docker"]

---

Docker Registry负责保存管理镜像，可以使用默认官方的Docker Hub，但需要登录，并且是公开的。  
私有的Registry，主要下面两种：  
* Docker Registry（Docker官方提供的镜像）
> 安装步骤参考[install Docker Registry](https://docs.docker.com/registry/deploying/#run-the-registry-as-a-service)

* Harbor(企业级Registry，提供权限管理和图形化界面)
> 安装步骤参考[install Harbor Registry](https://goharbor.io/docs/2.1.0/install-config/)