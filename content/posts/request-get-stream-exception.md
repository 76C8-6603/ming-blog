---

    title: "getInputStream() has already been called for this request"
    date: 2021-06-07
    tags: ["spring"]

---

# 背景
请求的ContentType为：
```http request
Content-Type: multipart/form-data;
```

在执行以下代码时报错：
```java
request.getReader();
```

详细错误： 
```log
getInputStream() has already been called for this request
```

# 问题原因
Spring预先读取并处理了multipart的内容，并将其封装为`MultipartHttpServletRequest`，如果再次通过request获取流就会抛错

# 解决方案
通过Spring的封装类获取文件流：
```java
MultipartHttpServletRequest multiRequest = (MultipartHttpServletRequest) request;
```