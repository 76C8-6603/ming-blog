---
title: "Spring自定义配置文件并映射到指定类中"
date: 2017-01-08
tags: ["spring"]

---

新建指定配置类TestConfiguration

该类需要的注解：
```java
@Configuration
@ConfigurationProperties(prefix="test")
@PropertySource("classpath:test.properties")
```
同时启动类上需要增加注解：
```java
@EnableConfigurationProperties({TestConfiguration.class})
```
