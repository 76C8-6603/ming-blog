---
    title: "Hive中的to_date和to_char"
    date: 2020-02-03
    tags: ["hive"]
    
---

hive的日期格式可由String类型保存，只能识别两种格式yyyy-MM-dd和yyyy-MM-dd HH:mm:ss。  
只要将日期转为这两种格式hive就能识别为日期。也就是不管to_date、to_char都是将日期格式化为字符串。

unix_timestamp(日期字符串,日期格式) 返回日期时间戳  
from_unixtime(日期时间戳,日期格式) 返回日期字符串  
 
to_date，to_char都用的一个公式，唯一不同的是to_date的目标日期格式是写死的  

1.to_date  
　　from_unixtime(unix_timestamp(来源日期，来源日期格式),'yyyy-MM-dd HH:mm:ss')  
　　例：
```sql
from_unixtime(unix_timestamp('2020/02/03 17:35:00','yyyy/MM/dd HH-mm-ss'),'yyyy-MM-dd HH:mm:ss')
```

2.to_char  
　　from_unixtime(unix_timestamp(来源日期，来源日期格式),目标日期格式)  
　　例：
```sql
from_unixtime(unix_timestamp('2020/02/03 17:35:00','yyyy/MM/dd HH-mm-ss'),'yyyy-MM-dd HH:mm:ss')
```