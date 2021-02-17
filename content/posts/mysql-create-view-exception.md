---

    title: "Mysql 创建视图报错：View's SELECT contains a subquery in the FROM clause"
    date: 2017-09-18
    tags: ["mysql"]

---

# 问题背景

使用sql:
```sql
create view test_view as
select a.column_1, b.column_2
from (select column_1 from table_1) a
         left join (select column_2 from table_2) b on a.column_1 = b.column_2
```

报错信息：
```log
View's SELECT contains a subquery in the FROM clause
```

# 问题原因
根据mysql官方文档，版本5.7之前都是不支持创建视图的from语句中有子查询的：   
> The SELECT statement cannot contain a subquery in the FROM clause.  
> >参考[mysql 5.6 create view](https://dev.mysql.com/doc/refman/5.6/en/create-view.html)  

从版本5.7开始不再有该限制。   
> 参考[mysql 5.7 create view](https://dev.mysql.com/doc/refman/5.7/en/create-view.html)
