---
    title: "Hive同环比实现"
    date: 2020-02-10
    tags: ["hive"]
    
---

```sql
select
          a.date
        , a.measure
        , case
                    when b.measure  is null
                              or b.measure=0
                              then null
                              else concat(  
　　　　　　　　　　　　　　　　　　　　 cast(  　　　　　　　　　　　　　　　　
                                        cast((if(a.measure is null, 0, a.measure)-if(b.measure is null,0,b.measure))*100/b.measure as decimal(10,2))　　　　　　　　　　　　　　　　　　　　 
                                    as string)　　　　　　　　　　　　　　　　　　
                            ,'%')
          end as ratio_column
from
          test_table a
          left join
                    test_table b
                    on
                              (
                                        to_date(from_unixtime(unix_timestamp(concat(a.date,''),'yyyyMM'),'yyyy-MM-dd HH:mm:ss')) 　　　　　　　　　　　　　　　　　　　　　　　　　　= add_months(to_date(from_unixtime(unix_timestamp(concat(b.date,''),'yyyyMM'),'yyyy-MM-dd HH:mm:ss')),+1)
                                        and 1 = 1
                              )
```

### 提醒：

　　1. 第一个join条件的'yyyyMM'可以根据字段date的具体格式改变，'yyyy-MM-dd HH:mm:ss'不需要改变

　　2. 该同环比没有任何分组和汇总，所以一旦date字段有重复值，很容易出现笛卡尔积，解决方案是确保join条件能够确定一条数据在表中的唯一性