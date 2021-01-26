---

    title: "Jackson反序列化的时候忽略实体中不存在的元素"
    date: 2017-08-12
    tags: ["jackson"]

---

```java
objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
```