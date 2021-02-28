---

    title: "Docker常用命令"
    date: 2019-01-05
    tags: ["docker"]

---
```shell
# 列出所有container
docker container ls -a

# 通过指定名称查询container
docker container ls -f name=mysql

# 删除所有停止的container
docker container prune

# 列出所有docker network
docker network ls

# 列出所有docker 镜像
docker images

# 启动容器
docker container start [container-name]

# 终止容器
docker container stop [container-name]

# 重启容器
docker container restart [container-name]

# 删除指定容器
docker container rm [container-name]

# 查看所有运行中的容器
docker ps

# 进入容器
docker exec -it mysql bash

# 删除镜像，注意之前必须停止容器并删除
docker rmi [镜像id]

# 安装并运行镜像，-p 代表端口映射，-e代表环境参数，-d 代表后台运行
docker run --name [容器名称] -p 3306:3306 -e MYSQL_ROOT_PASSWORD=jxcjvf09sfd_9dsf9 -d mysql:latest

# 根据当前目录下的Dockerfile构建镜像
docker build -t [imageName] .

# 拉镜像，镜像名称可指定registry服务器（例如 'docker pull localhost:5000/mysql'）
docker pull [镜像名称]

# tag镜像准备push
docker tag [镜像名称] [tag名称]

# push之前需要tag
docker push [tag名称]
```