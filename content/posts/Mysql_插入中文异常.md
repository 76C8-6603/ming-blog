---
    title: "mySql 插入中文异常 Incorrect string value: '***' for column"
    date: 2019-07-15 
    tags: ["mysql"]
    
---

问题是由mysql的编码问题造成，因为建表的时候没有指定utf-8作为字符集
建议重新建表，或者直接调整对应字段的字符集

### 1.修改mysql编码的

　　　　查看mysql的字符集：
```sql
        show variables where Variable_name like '%char%';
```

　　　　修改mysql的字符集：　　　

```sql
    　  mysql> set character_set_client=utf8;
    
    　　mysql> set character_set_connection=utf8;
    
    　　mysql> set character_set_database=utf8;
    
    　　mysql> set character_set_results=utf8;
    
    　　mysql> set character_set_server=utf8;
    
    　　mysql> set character_set_system=utf8;
    
    　　mysql> set collation_connection=utf8;
    
    　　mysql> set collation_database=utf8;
    
    　　mysql> set collation_server=utf8;
```

### 2.修改数据库的编码

　　　　查看数据库的字符集：
```sql
        show create database enterprises;
```

　　　　修改数据库的字符集：
```sql
        alter database enterprises character set utf8
```

### 3.修改表的编码

　　　　查看表的字符集：
```sql
        #位于建表语句的末尾
        show create table employees;
```

　　　　修改表的字符集：
```sql
        alter table employees character set utf8
```

　　　　修改字段的字符集：
```sql
        alter table employees change name name char(10) character set utf-8;
```