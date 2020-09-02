---
    title: "SpringBoot入口类常用注解"
    date: 2017-05-08
    tags: ["spring"]
    
---

```java
@SpringBootApplication(scanBasePackages="com.*.*")
@EnableScheduling
@EnableTransactionManagement
@MapperScan("com.*.**.*mapper")
@EnableConfigurationProperties({CustomConfiguration.class})
public class Application {}
```

1. `SpringBootApplication` Spring注解的扫描路径
2. `EnableScheduling` 开启Spring的定时任务
3. `EnableTransactionManagement` 开始Spring的事务管理
4. `MapperScan` 扫描MyBatis Mapper类的路径
5. `EnableConfigurationProperties` 自定义配置文件映射类