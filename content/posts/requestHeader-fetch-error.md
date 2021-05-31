---

    title: "HttpServletRequestWrapper 封装request后注解@RequestHeader为null"
    date: 2021-05-31
    tags: ["java","spring"]

---
# 问题背景
`HttpServletRequestWrapper`可以通过Filter传递，或者Interceptor直接forward来修改Request中的header，这里不讨论详细实现。  

这里出现的问题是，通过request的`getHeader`方法能正常获取对应header，但是通过`@RequestHeader`注解不行。

# 问题原因
```java
public String[] getHeaderValues(String headerName) {
    String[] headerValues = StringUtils.toStringArray(getRequest().getHeaders(headerName));
    return (!ObjectUtils.isEmpty(headerValues) ? headerValues : null);
}
```
上面是`ServletWebRequest`类的方法，也是`@RequestHeader`注解最终获取header的方法。  
可以看到是通过request对象的`getHeaders`方法来获取header的。  

所以`HttpServletRequestWrapper`除了`getHeader`，还要实现`getHeaders`方法。  

# 解决方案
```java
public class MutableHttpServletRequest extends HttpServletRequestWrapper {
    
        @Override
        public String getHeader(String name) {
            ...
        }

        /**
         * 这个重写是为了保证{@link org.springframework.web.bind.annotation.RequestHeader} 注解的正常调用
         * 因为该注解的逻辑是通过`getHeaders`方法获取请求头
         * @param name
         * @return
         */
        @Override
        public Enumeration<String> getHeaders(String name) {
            ...
            return Collections.enumeration(Arrays.asList(headerValue));
        }

        @Override
        public Enumeration<String> getHeaderNames() {
            ...
        }
    }
```

