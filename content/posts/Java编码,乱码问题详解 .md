---
    title: "Java编码,乱码问题详解"
    date: 2017-10-13
    tags: ["java"]
    
---

## 一、常见的编码格式
### 1.ASCII
　　基础编码，英文和西欧字符。

　　用一个字节的低7位表示，一共128个。

　　0~13是控制字符如换行、回车、删除等，32~126是打印字符，键盘输入。

### 2.IOS-8859-1
　　ASCII的扩展。

　　用一个字节表示，一共256个。

### 3.GB2312
　　中文编码字符集。

　　用两个字节表示，A1~A9是符号区，一共682个；B0~F7是汉字区，一共6763个。

　　编码需要查询对应码表，效率略低。

### 4.GBK
　　GB2312的扩展，能够兼容GB2312。

　　用两个字节表示，一共23940个码位，表示21003个汉字。

　　编码需要查询对应码表，效率略低。

### 5.UTF-16
　　UTF-16具体定义了Unicode字符在计算机的存取方法。

　　用两个字节表示Unicode的转化格式。

　　定长的展示方法，每两个字节表示一个字符，转化效率高，内存和硬盘多用此编码(JAVA内存存储格式UTF-16)。

　　采用顺序编码，不能对单个字符的编码进行校验，如果损坏，后面的码值都会受影响。

### 6.UTF-8
　　UTF-8具体定义了Unicode字符在计算机的存取方法。

　　用1-6个字节组成一个字符，汉字采用三个字节表示。

　　变长的展示方法，每个编码区域有不同的字码长度。

　　网络传输中很大一部分字符用一个字节就可以展示，UTF-16规范化的全部转为了两个字节，对于这些字符UTF-8只需要一个字节。

　　UTF-8如果中间一个码值损坏，后面的码值并不受影响。

　　相对于UTF-16，UTF-8有传输中资源占用小，数据更安全的优势，更适合网络传输，但UTF-16的编码规则相对简单，编码效率更高，适合本地内存和磁盘。

## 二、常见JAVA编码API
### 1.I/O　　
```java
InputStreamReader isr = new InputStreamReader(inputStream,"utf-8");

Charset StreamDecoder

OutputStreamWriter osw = new OutputStreamWriter(outputStream,"utf-8");

Charset StreamEncoder
```
### 2.内存操作
字符与字节的转换：　　　

```java
//String
String s = "中文字符";
byte[] b = s.getBytes("UTF-8");
String s1 = new String(b,"UTF-8");

//Charset
Charset charset = Charset.forName("UTF-8");
ByteBuffer byteBuffer = charset.encode(string);
CharBuffer charBuffer = charset.decode(byteBuffer);

//char和byte的软转换，将一个16bit的char拆分成两个8bit的byte来显示，实际值并没有被转换。
ByteBuffer heapByteBuffer = ByteBuffer.allocate(1024);
ByteBuffer byteBuffer = heapByteBuffer.putChar(c);
```
## 三、Java Web中涉及的编解码
### 1.URL编解码
PathInfo中文问题：

配置tomcat的server.xml：

<Connector URIEncoding="UTF-8"/>  
QueryString中文问题：  

QueryString是通过HTTP中的Header传到后台的，他的解码字符集默认是ISO-8859-1，

也可以通过Header的ContentType中的Charset来定义。

如何确定后端调取了ContentType中的字符集，需要在server.xml中配置（这个配置只针对QueryString有效）：

<Connector useBodyEncodingForURI="true"/>
 

### 2.HTTP Header的编解码
针对Header中的其他参数，比如Cookie,redirectPath等。

尽量不要传递非ASCII字符，如果必须，在传递之前用下面的API进行编码再传递：

org.apache.catalina.util.URLEncoder

### 3.POST表单的编解码
客户端获取参数为乱码后的解决思路：

　　1.将POST改为get，查看浏览器端是否有问题。

　　2.后端request.geCharacterEncdoing返回结果是否是预期编码。

//在第一次使用request.getParameter之前使用  
request.setCharacterEncoding(charset);
 

### 4.HTTP BODY的编解码
主要阐述从后台到前台的编解码：

```java
//对返回前台的数据进行编码，前台会首先根据这个值进行解码  
response.setCharacterEncoding(charset)  
```
```xml
<!-- 如果后台没有设置，会根据页面中的charset来解码，如果页面也有设置则用默认编码来解码 -->
<meta HTTP-equiv="Content-Type" content="text/html;charset=UTF-8"/>
<!-- JDBC读写数据时要和数据的内置编码保持一致 -->
url="jdbc:mysql://localhost:3306/DB?useUnicode=true&characterEncoding=UTF-8"
```
## 四、JS的编码问题
### 1.外部引入js文件
```xml
<!-- 浏览器会按照charset的设置来解析这个js文件，如果没有设置则默认按照当前页面的的编码设置来解析js文件 -->
<script src="de/mo/demo.js" charset="gbk"></script>
```
### 2.js的URL编码
```java
//对url根据UTF-8进行编码和解码，除了一些特殊字符"!""#""$""&""'""("")""*""+"",""-"".""/"":"";""=""?""@""_""~""0-9""a-z""A-Z"

//编码结果在每个码值前加一个"%"
encodeURI("http://localhost:8080/examples/servlets/servlet/来吧昆特牌吧孙子?inviter=杰洛特");

decodeURI("**编码内容**");
//对url根据UTF-8进行编码和解码，相对于encodeURI，它更加的彻底。排除的特殊字符为"!""'""("")""*""-"".""_""~""0-9""a-z""A-Z"
//编码结果在每个码值前加一个"%"
//它排除的字符比encodeURI更少，通常用于将URL作为参数的URL的编码，如示例如果不将参数URL中的&进行编码会影响到整个URL的完整性
"http://localhost/servlet?ref=" + encodeURIComponent("http://localhost:8080/examples/servlets/servlet/来吧昆特牌吧孙子?inviter=杰洛特&inviter=叶奈法");
decodeURIComponent("**编码内容**");
```
 
 

### 3.后端接收时解码
后端处理URL编解码靠的是 java.net.URLEncoder和java.net.URLDecoder这两个类。

后端对的对URL的编码同样也有排除的特殊字符，与前端的encodeURIComponent相对应。

```java
//后端直接获取传过来的URL参数会自动解码
//如果没有提前设置request.setCharacterEncoding()很容易出现编码不同而导致的乱码
request.getParameter();

//另一种方式是通过前台js对URL进行两次编码，后台不管通过什么进行第一次解码，都能得到正确的UTF-8编码，前台代码如下
encodeURIComponent(encodeURIComponent(url));
//第一次编码的结果（例如：%E2%A7）的百分号，会在第二次编码后将%变成%25（例如：%25E2%25A7）
//后台在执行request.getParameter()的时候会自动解码，不管当前容器的编码是什么得到的是正确的UTF-8编码（例如：%E2%A7）
```
 

## 五、其他需要编码的地方
### 1.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
```

### 2.Velocity
```properties
services.VelocityService.input.encoding=UTF-8
```

### 3.JSP
```html
<%@page contentType="text/html;charset=UTF-8"%>
```

 

注：本文是对“《深入分析Java Web技术内幕》许令波 著” 一书的相关内容的总结