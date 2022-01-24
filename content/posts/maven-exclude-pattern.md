---

    title: "Maven exclude all artifacts from a group"
    date: 2021-01-24
    tags: ["maven"]

---

```xml
<exclusion>
  <groupId>org.company</groupId>
  <artifactId>*</artifactId>
</exclusion>
```

> maven版本 3.2.1 以后可用，参考[maven issue](https://issues.apache.org/jira/browse/MNG-3832)
