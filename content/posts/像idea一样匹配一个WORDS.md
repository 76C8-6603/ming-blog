---
    title: "像IDEA一样匹配一个WORDS"
    date: 2020-01-16
    tags: ["regexp"]
    
---

```java
String.format("(?<![\\u4E00-\\u9FA5aa-zA-Z0-9_])%s(?![\\u4E00-\\u9FA5a-zA-Z0-9_])","独立字符不与任何其他字符相连")
```