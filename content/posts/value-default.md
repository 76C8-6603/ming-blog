---

    title: "@Value默认值"
    date: 2018-11-15
    tags: ["spring"]

---

```java
//代表默认值为空字符串
@Value("${spring.application.name:}")
private String name;

//代表默认值为字符串dev
@Value("${spring.profiles.active:dev}")
private String profileActive;

//默认值为true
@Value("${project.auth.isAdmin:true}")
private boolean isAdmin;
```