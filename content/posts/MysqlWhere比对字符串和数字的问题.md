---
    title: "Mysql Where条件判断 字符串和数字 是否相等时存在的问题"
    date: 2016-07-08
    tags: ["mysql"]
---

+ 测试数据  

|random|
|---|
|24|
|24uixcvkjklwer|

+ 查询sql1
```sql
SELECT random FROM table WHERE random = 24
```
该sql会把两条记录都查出来

+ 查询sql2
```sql
SELECT random FROM table WHERE random = '24'
```
该sql只会匹配第一条记录

+ 总结  
条件列为字符串的时候，保证用来判断的常量也是字符类型