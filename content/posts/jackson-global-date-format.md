---

    title: "Springboot Jackson全局日期格式处理"
    date: 2017-04-28
    tags: ["jackson","spring"]

---

通过修改springboot application.properties
```properties
spring.jackson.date-format= yyyy-MM-dd HH:mm:ss
spring.jackson.time-zone= GMT+8
```
上面是格式话日期

```properties
spring.jackson.serialization.write-dates-as-timestamps= true
```
上面是将日期全部转为时间戳