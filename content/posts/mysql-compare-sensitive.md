---

    title: "Mysql条件对比大小写敏感"
    date: 2017-05-08 
    tags: ["mysql"]

---

默认情况下mysql的对比条件是大小写不敏感的（latin1_general_ci)，所有不敏感的collate都以`_ci`结尾。  
要让对比条件大小写敏感，需要将collate设置为以`_cs`或者`_bin`结尾（比如`utf8_unicode_cs`和`utf8_bin`）  

# 检查当前的collate
你可以检测你的服务，数据库和连接的collate，通过：  
```sql
mysql> show variables like '%collation%';
+----------------------+-------------------+
| Variable_name        | Value             |
+----------------------+-------------------+
| collation_connection | utf8_general_ci   |
| collation_database   | latin1_swedish_ci |
| collation_server     | latin1_swedish_ci |
+----------------------+-------------------+
```
你也可以检测表的collate，通过:  
```sql
mysql> SELECT table_schema, table_name, table_collation 
       FROM information_schema.tables WHERE table_name = `mytable`;
+----------------------+------------+-------------------+
| table_schema         | table_name | table_collation   |
+----------------------+------------+-------------------+
| myschema             | mytable    | latin1_swedish_ci |
```

# 改变 collate
你可以改变数据库，表，或者列的collate为大小写敏感：  
```sql
-- Change database collation
ALTER DATABASE `databasename` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;

-- or change table collation
ALTER TABLE `table` CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin;

-- or change column collation
ALTER TABLE `table` CHANGE `Value` 
    `Value` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin;
```