---
    title: "全局获取request"
    date: 2018-01-09
    tags: ["java"]
    
---

1. 交于Spring管理的类，通过注解调用
```java
@Component
public class Test{
    @Autowired
    private HttpServletRequest httpServletRequest;
}
```

2. 通过静态方法调用
```java
HttpServletRequest httpServletRequest = ((ServletRequestAttributes)RequestContextHolder.getRequestAttributes()).getRequest();
```