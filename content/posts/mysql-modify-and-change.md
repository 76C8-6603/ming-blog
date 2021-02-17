---

    title: "Mysql modify和change的区别"
    date: 2016-03-21
    tags: ["mysql"]

---
他们之间的区别就是是否能够同时修改列名和列的定义。  

# CHANGE
你可以修改列名和列定义
```sql
ALTER TABLE t1 CHANGE a b BIGINT NOT NULL
```

# MODIFY
可以修改列定义，但是不能修改列名
```sql
ALTER TABLE t1 MODIFY b INT NOT NULL
```

# RENAME COLUMN
可以修改列名，但是不能修改列定义
```sql
ALTER TABLE t1 RENAME COLUMN b TO a
```

> 详情参考[doc](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html#alter-table-redefine-column)  