---
    title: "根据Method获取所有参数名"
    date: 2017-06-06
    tags: ["java"]
    
---
```java
LocalVariableTableParameterNameDiscoverer discoverer = new LocalVariableTableParameterNameDiscoverer();
discoverer.getParameterNames(method);
```
详情参考[API文档](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/LocalVariableTableParameterNameDiscoverer.html)