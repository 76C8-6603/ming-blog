---

    title: "@Autowired注解直接修饰在成员变量时提醒Field injection is not recommended"
    date: 2019-12-13
    tags: ["spring"]

---
# Spring依赖注入方式
1. 直接修饰成员变量，也就是提醒不推荐的情况
```java
@RestController
public class TestController{
    @Autowired
    private TestService testService;
}
```
2. 修饰构造函数，@Autowired可省略
```java
@RestController
public class TestController{
    private TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }
}
```
3. 修饰setter函数，@Autowired可省略
```java
@RestController
public class TestController{
    private TestService testService;

    public void SetTestService(TestService testService) {
        this.testService = testService;
    }
}
```

# 不推荐直接修饰的原因
* `@Autowired`不能作用在final的成员变量上  
* 直接修饰成员变量会导致变量直接依赖Spring容器，脱离Spring容器就无法初始化，然而通过构造函数或setter函数的方式都是可以脱离Spring容器的使用的  
* 直接修饰的方式会让你忽略当前类有多少依赖，不利于代码重构和优化