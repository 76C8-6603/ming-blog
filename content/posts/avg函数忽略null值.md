---
    title: "avg函数忽略null值"
    date: 2018-06-05
    tags: ["mysql"]
    
---

avg函数对值为null的行，会忽略不计
解决方案
    
```sql
    avg((coalesce(column,0))
```
