---
    title: "Spring @Value注解无法正确赋值问题"
    date:  2019-09-05 
    tags: ["spring"]
    
---

正确的调用方式为：

```java
@Component
public class IconProperties {
   @Value("${icon.url}")
    private String url;
}
public class test{
    @Autowired
    IconProperties icon;
    public void test(){  String url = icon.url; }
}
```
 

这里有三个需要注意的点：

1.@Value赋值是否正确

2.IconProperties是否有@Component，或者其他代表着该类交于Spring容器管理的注解

3.在调用参数时通过@Autowired实例化类来调取