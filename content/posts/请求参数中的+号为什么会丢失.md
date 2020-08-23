---
    title: "请求参数中的+号为什么会丢失,如何保证参数完整"
    date: 2018-08-07
    tags: ["java"]
    
---

最近在开发中碰见一个问题，后端代码调用接口，在请求端参数没有任何问题，但是当接口接收到参数时，其中的加号全部变为了空格。

在查阅资料后发现是URLDecoder方法的问题，以下是URLDecoder的文档说明：

The following rules are applied in the conversion:

* The alphanumeric characters "a" through "z", "A" through "Z" and "0" through "9" remain the same.
* The special characters ".", "-", "*", and "_" remain the same.
* The plus sign "+" is converted into a space character "   " .
* A sequence of the form "%xy" will be treated as representing a byte where xy is the two-digit hexadecimal representation of the 8 bits. Then, all substrings that contain one or more of these byte sequences consecutively will be replaced by the character(s) whose encoding would result in those consecutive bytes. The encoding scheme used to decode these characters may be specified, or if unspecified, the default encoding of the platform will be used  

文档中很明显，URLDecoder会将加号转变为空格，其他的符号".", "-", "*", "_"将保持不变。

Spring mvc框架在给参数赋值的时候调用了URLDecoder，那要解决这个问题，需要在请求的时候对"+"做处理：

```java
String plusEncode = URLEncoder.encode("+", "UTF-8");  
param = param.replaceAll("\\+", plusEncode);  
```
这里在请求发送前，将加号用URLEcoder进行编码，并将参数json中的所有加号替换成编码后的字符。  