---

    title: "db2 sum函数报错Arithmetic overflow..."
    date: 2019-11-18
    tags: ["db2"]

---

# 完整异常
> Arithmetic overflow or other arithmetic exception occurred.. SQLCODE=-802, SQLSTATE=22003, DRIVER=4.26.14

# 报错sql
```sql
SELECT SUM(C_1788) FROM table
```
c_1788列是integer类型

# 报错原因
c_1788列数值长度为9，sum值肯定溢出
