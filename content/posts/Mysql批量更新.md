---
    title: "Mysql批量更新"
    date:  2019-07-19 
    tags: ["mysql"]
    
---

多个where条件，每个条件对应的更新值不同，需要mysql批量更新

```sql
UPDATE 
   test_table
SET
    test_target = test_id CASE
    WHEN "123" THEN "456"
    WHEN "789" THEN "101"
    END
WHERE
    test_id in ['123','789']
```
但是在程序中，直接写常量的情况太少，大多数都需要变量遍历

下面是mybatis的应用：
```xml
UPDATE
     table
SET
    target = CASE id
<foreach collection="items" item="item"   close=" END" >
    WHEN #{item.id} THEN #{item.target}
</foreach>
WHERE
    apply_id IN
<foreach collection="items" item="item" open="(" close=")" separator="," >
    #{item.id}
</foreach>
```