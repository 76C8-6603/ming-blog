---

    title: "Mysql Like语句匹配下划线时无法得到正确数据"
    date: 2016-05-11
    tags: ["mysql"]

---

# 示例sql
```sql
SELECT * FROM table WHERE field LIKE '%_%'
```
目的是获取中间有下划线的field，但是这样的sql无法获取到期望的结果

# 问题原因
like语句中除了百分号是通配符，下划线也是通配符。只是百分号代表一个或者多个字符，下划线代表一个字符（比如`hello`，可以通过`__llo`匹配）。如果要把百分号或者下划线作为匹配内容，那么需要在前面加上斜杠：`\`：  
```sql
SELECT * FROM table WHERE field LIKE '%\_%'
```