---

    title: "h2删除视图失败，提示有其他视图依赖于该视图"
    date: 2018-10-05
    tags: ["h2"]

---
# 问题背景
```sql
DROP VIEW temp_view;
```

报错信息：  
```log
Can't drop temp_view,because *** depend on it
```

# 解决方案
```sql
DROP VIEW temp_view CASCADE ;
```
该sql会删除所有依赖的视图