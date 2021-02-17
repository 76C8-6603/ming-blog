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

## 2.3 原因
oracle分页的写法显得特别臃肿和多余，但是对于旧版本来说没得选择，这个写法规避了很多排序的问题并且高效  
首先要明白一个概念，`ROWNUM`并不是跟行绑定的，他是sql执行完`from where`后，并在排序和聚合前，每得到一个结果就分配一个`ROWNUM`  
所以像下面这种写法肯定得不到任何结果  
```sql
SELECT * 
FROM 
    t
WHERE ROWNUM > 1
```
当`from`获取到第一行，因为还没有经过`where`判断，所以没有分配`ROWNUM`，只能读取到`ROWNUM`的默认值1，然而这个`where`条件肯定不能成立，也就是说`ROWNUM`没有分配到第一行（分配逻辑包含自增），永远到不了2，该查询肯定没有结果  
### 2.3.1 为什么要用子查询
当使用排序时，因为`ROWNUM`的分配是在排序之前的，所以是先得到10条数据然后排序，而不是先排序后取10条
```sql
SELECT *
FROM 
    t 
WHERE 
    ROWNUM <= 10
ORDER BY 
    col DESC 
```

需要封装一个子查询后再限制`ROWNUM`
```sql
SELECT * 
FROM
    (
        SELECT *
        FROM
            t 
        ORDER BY 
            col DESC 
    )
WHERE 
    ROWNUM <= 10
```

### 2.3.2 对Top-N的优化
使用子查询`ROWNUM`的方式，另外一个原因是oracle对他进行了优化  
如果直接进行查询，再对结果进行筛选，像下面的例子
```sql
SELECT *
FROM 
    t
ORDER BY 
    col DESC 
```
当表的数据有百万甚至千万行的时候，这个表的所有数据都要放到内存中进行排序，如果用于排序的内存满了，还需要暂存到磁盘上。
大量io和磁盘读写，耗费时间，并且占用资源，仅仅只是为了获取10行数据  

使用子查询`ROWNUM`的方式，如下
```sql
SELECT * 
FROM
    (
        SELECT *
        FROM
            t 
        ORDER BY 
            col DESC 
    )
WHERE 
    ROWNUM <= 10
```
ORACLE对他进行了优化，像上面的例子，当查询一开始，会将最开始的10个`col`值保存到内存中排序，然后获取第11个跟内存中的第10个进行比较  
如果在区间外，那么直接忽略这个值。如果在区间内，那么删除原本第10个值，追加第11个，重新进行排序  
按照这个逻辑，遍历时只需要对内存中的10个值进行排序，节省大量资源和时间

### 2.3.3 分页注意事项
与top-n的随机性不一样，分页需要同样条件下每次的查询结果都是一致的，但如果排序列有大量的重复值，一致性无法保证
```sql
SELECT *
FROM 
(
    SELECT a.*,ROWNUM rn 
    FROM
        (
            SELECT *
            FROM
                t 
            ORDER BY 
                col DESC 
        ) a
    WHERE 
        ROWNUM <= 10
)
HWERE rn >=6
```
上面的例子中如果`col`列有大量重复值，每次查询的结果都会不一样  
解决方案是在order by语句中追加`ROWID`，因为`ROWID`在表中是唯一的
```sql
SELECT *
FROM 
(
    SELECT a.*,ROWNUM rn 
    FROM
        (
            SELECT *
            FROM
                t 
            ORDER BY 
                col DESC ,ROWID
        ) a
    WHERE 
        ROWNUM <= 10
)
HWERE rn >=6
```
