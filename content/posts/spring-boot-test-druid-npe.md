---

    title: "Spring boot test执行的时候，druid空指针"
    date: 2021-07-18
    tags: ["druid"]

---

### 背景
Spring boot执行单元测试时，能够正常初始化Context，但是到执行Mock测试时报错：  
```
java.lang.NullPointerException
	at com.alibaba.druid.support.http.WebStatFilter.doFilter(WebStatFilter.java:94)
	at org.springframework.test.web.servlet.setup.PatternMappingFilterProxy.doFilter(PatternMappingFilterProxy.java:102)
	at org.springframework.mock.web.MockFilterChain.doFilter(MockFilterChain.java:134)
```

### 原因
根据异常，报错的类是druid的`WebStatFilter`类，该类主要做统计工作，需要进行初始化才能正常工作。然而Mock调用时不能触发相关初始化逻辑  
> 参考[druid issue](https://github.com/alibaba/druid/issues/2050)  

### 解决方案
1. 添加测试配置，屏蔽统计filter    
```properties
spring.datasource.druid.web-stat-filter.enabled=false
```

2. 更新druid版本  
报错版本：  
```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.1.9</version>
</dependency>
```

测试正常版本：
```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.2.6</version>
</dependency>
```