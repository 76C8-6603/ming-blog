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
docker exec -it mysql [bash][/bin/bash][/bin/sh]

# 删除镜像，注意之前必须停止容器并删除
docker rmi [镜像id]

# 安装并运行镜像，-p 代表端口映射，--network代表使用哪种网络（host代表宿主机网络，指定后不需要在指定-p。还有默认的bridge，和不指定none）
# -e代表环境参数，-d 代表后台运行
docker run --name [容器名称] -p 3306:3306 --network host -e MYSQL_ROOT_PASSWORD=jxcjvf09sfd_9dsf9 -d mysql:latest

# 根据当前目录下的Dockerfile构建镜像
docker build -t [imageName] .

# 拉镜像，镜像名称可指定registry服务器（例如 'docker pull localhost:5000/mysql'）
docker pull [镜像名称]

# tag镜像准备push
docker tag [镜像名称] [tag名称]

# push之前需要tag
docker push [tag名称]

# 实时查看容器日志
docker logs -f [容器名称]

# 查看registry中的镜像
curl <仓库地址>/v2/_catalog

# 查询镜像tag(版本）
curl <仓库地址>/h2/<镜像名>/tags/list

# 创建并启动容器
docker-compose up -d

# 将容器内部的文件拷贝到宿主机
docker cp mawall_ppcl:/data/dist  /home/data/test/

# 查看当前容器的资源占用情况
docker stats

# 在容器外部直接执行命令
docker exec -i custom-mysql mysql -uroot -p

# 检查容器的配置信息，以格式化json展现，包括容器的运行状态信息
docker inspect elasticsearch

# 查看容器网段
docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)

# 保存离线镜像
docker save -o .\firstTry.tar $(docker images --format "{{.Repository}}:{{.Tag}}")

# 从本地加载离线镜像
docker load -i .\firstTry.tar

# 删除所有无效镜像
docker image prune 
```