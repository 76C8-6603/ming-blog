---

    title: "给运行中的容器添加env或者volume"
    date: 2020-05-20
    tags: ["docker"]

---

### 背景
给运行中的容器添加env或者volume，方法有很多种，但是不停止容器不可能，具体的讨论可以参考：[stackoverflow](https://stackoverflow.com/questions/28302178/how-can-i-add-a-volume-to-an-existing-docker-container)  
总结一下，主要有两种方式，一种是commit当前镜像，删容器重新创建，另外一种是关闭docker守护进程，直接修改容器的配置文件，但是第二种重启又会失效。  
这里只讨论第一种实现方式。  

### 实现
```shell
# 备份当前镜像的持久化数据
docker cp mysql:/var/lib/mysql /tmp/mysql

# 从指定容器生成镜像，以保存容器状态
docker commit mysql mysql:custom

# 终止删除已有容器
docker stop mysql && docker rm mysql

# 重新生成并运行容器
docker run -d -v /tmp/mysql:/var/lib/mysql mysql:custom
```
[参考文章](https://dev.to/mehulcs/add-new-volumes-to-a-running-container-in-docker-compose-nhh)
