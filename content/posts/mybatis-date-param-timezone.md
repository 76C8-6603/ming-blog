---

    title: "Mybatis 注入date参数时区不对"
    date: 2019-01-03
    tags: ["mybatis","spring"]

---
### 背景
```xml
<select id="sum" resultType="java.math.BigDecimal">
        select
            sum(amount)
        from
            test_table
        where
            create_time &lt; #{curDate}

</select>
```
参数`#{curDate}`直接传递的date，但是在跟踪日志时发现，参数会受系统时区影响  

### 解决方案
Spring boot启动类中添加时区信息  
```java
@SpringBootApplication
public class Application() {
    public static void main(String[] args) {
        //时区修改
        TimeZone.setDefault(TimeZone.getTimeZone("GMT+8"));

        SpringApplication.run(Application.class, args);
    }
}
```