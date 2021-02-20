---

    title: "Spring boot @Value设定默认值 配置文件中没有也不会报错"
    date: 2018-07-11
    tags: ["spring"]

---

# 背景
默认情况下`@Value`注解如果没有在`properties`文件中存在对应值，那么启动项目的时候会直接报错。  

# 解决方案
可以给`@Value`注解设定默认值，这样就算配置文件中没有对应值，也不会报错。  
```java
@Component
public class ConfigurationProperties{
    @Value("${custom.values.val1:#{null}")
    private String val1;
    
    @Value("${custom.values.val2:hello}")
    private String val2;
}
```
可以通过`#{null}`的方式将默认值设为null