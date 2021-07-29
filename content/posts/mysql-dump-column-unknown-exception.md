---

    title: "mysqldump throws: Unknown table 'COLUMN_STATISTICS' in information_schema (1109)"
    date: 2021-07-29
    tags: ["mysql"]

---
原因是因为mysqldump8新加了`--column-statistics=1`属性，可以通过如下命令屏蔽：
```shell
mysqldump --column-statistics=0 --host=<server> --user=<user> --password=<password> 
```
或者修改mysql的配置文件
```
[mysqldump]
column-statistics=0
```
/etc/my.cnf 或者 ~/.my.cnf