---

    title: "Java保存密文文件bytes"
    date: 2021-06-21
    tags: ["java"]

---
# 背景
项目需要保存keytab文件，keytab文件中有密文  
现在需要将keytab文件转为bytes字符串，并且之后还能通过字符恢复keytab文件  

# 问题
通过bytes字符串恢复的文件，无法再通过校验  

# 解决方案
将文件转字符串：  
```java
MulipartFile keytab;
new String(keytab.getBytes(), StandardCharsets.ISO_8859_1);
```

通过bytes恢复文件：  
```java
String keytabStr;
keytabStr.getByte(StandardCharsets.ISO_8859_1);
```

总结一下就是通过`ISO_8859_1`转换。  
但是这种方案并不推荐，当前项目使用是因为框架和工期的限制，涉及密文文件推荐通过流来处理，不要转为字符操作。