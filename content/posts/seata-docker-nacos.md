---

    title: "seata-docker-nacos"
    date: 2021-09-24
    tags: ["seata"]

---
### 背景
通过docker拉取的官方镜像，没有指定版本。但是在配置nacos的时候，出现无法注册的情况。官方文档和网上的文章大部分都围绕`file.conf`和`registry.conf`两个文件进行配置，但是实践过程中，没有在`/seata-server/resources/`目录下发现这两个文件，并且手动新增后也没有任何效果。

根据[官方镜像仓库](https://hub.docker.com/r/seataio/seata-server/tags?page=1&ordering=last_updated) 确定拉下来的是1.5的版本，但是官网和大部分文章都是基于1.4.2或以前的版本进行的配置，实测在1.5上完全不能生效。

### 解决方案
* 手动指定版本到1.4.2然后根据`file.conf`和`registry.conf`两个文件进行配置（网上文章很多，这里不做赘述）
* 1.5版本需要修改`/seata-server/resources/`目录下的`application.yml`文件(下面主要针对这种情况进行阐述)


#### 1. 搭建nacos环境
搭建nacos环境完成后，新建命令空间，并记住命令空间的id（这里的命令空间id手动指定为`seata`）  
然后在指定命名空间新建配置，设置`dataId`为`seataServer.properties`

#### 2. 搭建seata存储环境
mysql数据库新建`seata`库，并执行[脚本](https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql)  

#### 3. 部署seata
```shell
docker run --name seata -d \
-e SEATA_PORT=8091 \
--restart=always \
-v /Users/admin/seata-server:/seata-server \
--privileged=true \
-p 8091:8091 \
 seataio/seata-server
```
修改为宿主机对应路径`/Users/admin/seata-server`

#### 4. 修改seata配置文件
在宿主机对应配置路径修改`application.yml`
```yaml
server:
  port: 7091

spring:
  application:
    name: seata-server

logging:
  config: classpath:logback-spring.xml
  file:
    path: ${user.home}/logs
  extend:
    logstash-appender:
      destination: 127.0.0.1:4560
    kafka-appender:
      bootstrap-servers: 127.0.0.1:9092
      topic: logback_to_logstash

seata:
  config:
    # support: nacos 、 consul 、 apollo 、 zk  、 etcd3
    type: nacos
    nacos:
      server-addr: 127.0.0.1:8848
      namespace: seata
      group: SEATA_GROUP
      username: nacos
      password: nacos
      data-id: seataServer.properties
  registry:
    # support: nacos 、 eureka 、 redis 、 zk  、 consul 、 etcd3 、 sofa
    type: nacos
    nacos:
      application: seata-server
      server-addr: 127.0.0.1:8848
      group: SEATA_GROUP
      namespace: seata
      cluster: default
      username: nacos
      password: nacos
  store:
    # support: file 、 db 、 redis
    mode: db
    db:
      datasource: druid
      db-type: mysql
      driver-class-name: com.mysql.jdbc.Driver
      url: jdbc:mysql://127.0.0.1:3306/seata?rewriteBatchedStatements=true
      user: root
      password: root
      min-conn: 5
      max-conn: 100
      global-table: global_table
      branch-table: branch_table
      lock-table: lock_table
      distributed-lock-table: distributed_lock
      query-limit: 100
      max-wait: 5000
  server:
    service-port: 8091
```
* 修改对应的nacos，mysql的ip:port
* 并把之前添加的nacos命名空间填到`namespace`处  
* 更多配置可参考同目录下的`application-example.yml`

#### 5. 重启seata



