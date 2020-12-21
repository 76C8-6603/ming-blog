---

    title: "db2 cast decimal异常"
    date: 2019-11-20
    tags: ["db2"]

---

# 完整异常
```log
[42611][-604] The length, precision, or scale attribute for column, distinct type, structured type, array type, attribute of structured type, routine, cast target type, type mapping, or global variable "decimal(38, 2)" is not valid.. SQLCODE=-604, SQLSTATE=42611, DRIVER=4.26.14 [56098][-727] An error occurred during implicit system action type "2". Information returned for the error includes SQLCODE "-604", SQLSTATE "42611" and message tokens "decimal(38, 2)".. SQLCODE=-727, SQLSTATE=56098, DRIVER=4.26.14
```

# 报错sql
```sql
SELECT cast(a as decimal(38,2)) from table
```

# 报错原因
DECIMAL (p, s)
p = 1 to 31; s = 1 to 31
