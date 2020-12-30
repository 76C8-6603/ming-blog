---

    title: "Mybatis返回delete语句删除的行"
    date: 2016-07-05
    tags: ["mybatis","mysql"]

---

```xml
<select id="removeSomeStuff" parameterType="map" resultType="WhateverType" flushCache="true">
    delete from some_stuff where id = #{id}
    RETURNING *
</select>
```
`flushCache`属性执行二级缓存删除