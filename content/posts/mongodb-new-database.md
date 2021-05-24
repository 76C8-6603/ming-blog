---

    title: "Mongodb create database"
    date: 2021-05-24
    tags: ["mongodb"]

---

# 语法
```shell
use DATABASE_NAME
```

# 例子
如果你想创建一个名称为`mydb`的数据库：
```
>use mydb
switched to db mydb
```
检查当前选中的数据库：
```
>db
mydb
```
如果你想查看数据库列表，可以使用以下命令：
```
>show dbs
local 0.0GB
test  0.0GB
```
你会发现你刚才创建的数据库并没有展现，那是因为数据库至少有一个document才会展示在列表中
```
>db.movie.insert({"name":"tutorials point"})
>show dbs
local      0.78125GB
mydb       0.23012GB
test       0.23012GB
```
MongoDB默认的数据库是`test`。也就是说如果你没有创建任何数据库，那么collection将会保存在test数据库中