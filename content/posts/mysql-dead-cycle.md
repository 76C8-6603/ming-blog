---
    title: "Mysql循环语句，死循环解决办法（mysql process）"
    date: 2019-08-15
    tags: ["mysql"]
    
---

```sql
delimiter //                            #定义标识符为双斜杠
drop procedure if exists test;          #如果存在test存储过程则删除
create procedure test()                 #创建无参存储过程,名称为test
  begin
    declare i int;                      #申明变量
    set i = 0;                          #变量赋值
    while i < 50 do                     #结束循环的条件: 当i大于10时跳出while循环
      INSERT INTO table_test
      ( name
      )
      VALUES
        (
          '123'
        );
      SET i=i+1;　　　　　　　　　　　　　　 #循环条件不能丢
    end while;                          #结束while循环
    select * from test;                 #查看test表数据
  end
    //                                      #结束定义语句
call test();                            #调用存储过程
```
以上是mysql循环语句，但我在执行的时候忘了加上SET 循环条件，导致SQL无限循环往表里插入数据

这种情况光是关闭SQL窗口，是不管用的，SQL会在后台继续运行，需要找到对应线程，手动杀死
```sql
# 展示所有运行中的进程，进程信息里会展示对应SQL
SHOW PROCESSLIST;

# 或者通过sql具体筛选进程
SELECT * FROM information_schema.PROCESSLIST WHERE DB = ‘test’

# 杀掉对应线程id
KILL 123456;
```