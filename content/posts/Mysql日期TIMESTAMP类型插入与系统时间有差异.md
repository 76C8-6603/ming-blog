---
    title: "Mysql 日期TIMESTAMP类型插入，与系统时间有差异"
    date: 2019-07-23
    tags: ["mysql"]
    
---

1.数据库url后追加 
```
&serverTimezone=Asia/Shanghai
```

2.修改数据库默认时区
```sql
show variables like "%time_zone%";#查询当前时区

set global time_zone = '+8:00'; #修改mysql全局时区为北京时间，即我们所在的东8区

set time_zone = '+8:00'; #修改当前会话时区

flush privileges; #立即生效
```