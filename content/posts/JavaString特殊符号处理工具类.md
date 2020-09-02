---
    title: "JavaString 特殊符号处理工具类"
    date: 2017-05-26
    tags: ["java"]
    
---

####  Java, Java Script, HTML, JSON, CSV and XML
`org.apache.commons.lang3.StringEscapeUtils`
```java
//使用示例
StringEscapeUtils.escapeCsv("");
SqtringEscapeUtils.escapeXml("");
```
> [api文档](https://commons.apache.org/proper/commons-lang/javadocs/api-release/index.html)

#### Regexp
> [正则表达式转义所有特殊符号](/2017/05/正则表达式转义所有特殊符号/index.html)

#### 其他
`com.google.common.escape.Escapers`
```java
Escaper build = Escapers.builder().addEscape('$', " ").build();
String str = build.escape("$$$$");
```
> [api文档](https://guava.dev/releases/22.0/api/docs/com/google/common/escape/Escapers.html)

