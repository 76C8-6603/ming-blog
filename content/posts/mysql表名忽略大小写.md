---
title: "Mysql表名忽略大小写"
date: 2020-08-10T13:18:03+08:00
tags: ["mysql"]

---

跟参数lower_case_table_names相关

执行语句，查询该参数值
```sql
SHOW VARIABLES LIKE ‘%case%’
```

lower_case_table_names参数值为0代表大小写敏感

需要将lower_case_table_names的值改为1

编辑/etc下的my.cnf文件，可能在根目录下，或者在mysql目录下

添加如下配置，然后重启mysql
```properties
[mysqld]
lower_case_table_names=1
```
