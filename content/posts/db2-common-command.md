---

    title: "db2常用命令"
    date: 2021-06-24
    tags: ["db2"]

---

如果是docker db2容器，可以通过如下命令登陆容器:  
```shell
docker exec -ti mydb2 bash -c "su - ${DB2INSTANCE}"
```
{DB2INSTANCE}一般是`db2inst1`，详情参考[dockerhub db2](https://hub.docker.com/r/ibmcom/db2)  
登录容器后，输入`db2`即可进入控制台

```shell
# 创建database，注意创建需要时间，会等待一阵
CREATE DATABASE db1

# 进入database
CONNECT TO db1

# 创建schema
CREATE SCHEMA sche01

# 进入schema
SET sche01
```