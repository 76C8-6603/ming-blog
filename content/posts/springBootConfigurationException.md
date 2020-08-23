---
    title: "spring boot configuration annotation processor not found in classpath"
    date:  2019-07-17 
    tags: ["spring"]
    
---

配置有@ConfigurationProperties 注解的类，有如下提示
```spring boot configuration annotation processor not found in classpath```  
pom追加配置如下依赖即可
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```