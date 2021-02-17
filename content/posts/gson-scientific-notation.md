---

    title: "阻止Gson将long类型的字段转为科学计数法"
    date: 2017-06-08
    tags: ["java"]

---

```java
GsonBuilder gsonBuilder = new GsonBuilder();
gsonBuilder.setLongSerializationPolicy( LongSerializationPolicy.STRING );
Gson gson = gsonBuilder.create();
```