---
    title: "Java读取文件内容文件头有\ufeff"
    date: 2019-09-18 
    tags: ["java"]
    
---

"\ufeff"是UTF-8 BOM编码的文件头，代表该文件按照什么字节顺序排序

调用java的工具类
\[UnicodeInputStream]即可解决这个问题  
```java
//第二个参数targetEncoding为null时在getDetectedEncoding方法中会自动检测编码类型
UnicodeInputStream unicodeInputStream = new UnicodeInputStream(inputStream, null);
String enc = unicodeInputStream.getDetectedEncoding();
//UnicodeInputStream内部由PushbackInputStream实现，跳过了无意义的文件头
bufferedReader = new BufferedReader(new InputStreamReader(unicodeInputStream, enc));
```