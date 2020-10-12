---
    title: "Oracle limit 问题"
    date: 2016-01-06
    tags: ["oracle"]
---

# 1.Oracle 12c R1 (12.1)支持limit语句
从`Oracle 12c R1 (12.1)`版本开始，oracle开始支持limit语句，但是跟熟悉的`limit(1, 10)`语句还是有区别的  
oracle的语句更复杂，但是有更多选项能做更多的事。参考oracle limit[完整的语法](https://docs.oracle.com/database/121/SQLRF/statements_10002.htm#BABBADDD) (关于oracle内部是如何实现limit的可以参考[这个回答](https://stackoverflow.com/questions/470542/how-do-i-limit-the-number-of-rows-returned-by-an-oracle-query-after-ordering/57547541#57547541))  
  
那么一个oracle limit语句到底应该怎么写了，比如要取21-30行的数据：
```sql
SELECT * 
FROM   sometable
ORDER BY name
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;
```  
上面是一个简单直接的例子，下面是引用自[官方说明](https://oracle-base.com/articles/12c/row-limiting-clause-for-top-n-queries-12cr1)的更多实例:  
## 1.1 初始化
```sql
DROP TABLE rownum_order_test;

CREATE TABLE rownum_order_test (
  val  NUMBER
);

INSERT ALL
  INTO rownum_order_test
  INTO rownum_order_test
SELECT level
FROM   dual
CONNECT BY level <= 10;

COMMIT;
```  
表`rownum_order_test`里的内容：
```sql
SELECT val
FROM   rownum_order_test
ORDER BY val;

       VAL
----------
         1
         1
         2
         2
         3
         3
         4
         4
         5
         5
         6
         6
         7
         7
         8
         8
         9
         9
        10
        10

20 rows selected.
```

## 1.2 Top-N 查询
```sql
SELECT val
FROM rownum_order_test
ORDER BY val DESC 
FETCH FIRST 10 ROWS ONLY;

       VAL
----------
        10
        10
         9
         9
         8

5 rows selected.
```
## 1.3 WITH TIES
使用`WITH TIES`语句，在最后一行有重复值存在时，将会把最后一行的重复值都返回。在这个例子中第五行的值是8，但是根据排序，有两个行数值都为8的，所以这两个都保留  
```sql
SELECT val
FROM   rownum_order_test
ORDER BY val DESC
FETCH FIRST 5 ROWS WITH TIES;

       VAL
----------
        10
        10
         9
         9
         8
         8

6 rows selected.

```

## 1.4 前百分比数据量限制
```sql
SELECT val
FROM   rownum_order_test
ORDER BY val
FETCH FIRST 20 PERCENT ROWS ONLY;

       VAL
----------
         1
         1
         2
         2

4 rows selected.

```

## 1.5 分页
```sql
ELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 4 ROWS ONLY;

       VAL
----------
         3
         3
         4
         4

4 rows selected.
```
代表从OFFSET+1开始取4行  

## 1.6 offset和百分比结合
```sql
SELECT val
FROM   rownum_order_test
ORDER BY val
OFFSET 4 ROWS FETCH NEXT 20 PERCENT ROWS ONLY;

       VAL
----------
         3
         3
         4
         4

4 rows selected.
```

# 2.旧版本不支持limit语句
旧版本的oracle不支持limit语句，需要通过子查询来实现，原因可参考[On ROWNUM and limiting results](https://blogs.oracle.com/oraclemagazine/on-rownum-and-limiting-results)  

## 2.1 Top-N
```sql
select *
from  
    ( select * 
    from emp 
    order by sal desc ) 
where ROWNUM <= 5;
```

## 2.2 区间
```sql
select * from 
( select a.*, ROWNUM rnum from 
  ( <your_query_goes_here, with order by> ) a 
  where ROWNUM <= :MAX_ROW_TO_FETCH )
where rnum  >= :MIN_ROW_TO_FETCH;
```
