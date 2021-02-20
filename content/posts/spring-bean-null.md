---

    title: "Spring bean为null启动报错"
    date: 2017-11-08
    tags: ["spring"]

---

# 背景
如果配置bean的时候出现null值，并且被其他bean所引用。那么启动的时候就有可能出现失败的情况。  
```java
@Configuration
public class BeanConfiguration{
    @Bean
    public Other getOther() {
        return null
    }
}
```
因为配置的bean为null，Spring会直接忽略这个bean：  
```log
User-defined bean method '***' in '***' ignored as the bean value is null
```

# 解决方案
如果一个bean是可能为null的，那么在引用他的时候，需要将`@Autowire`注解的`required`属性设置为`false`。
```java
public class Test{
    @Autowire(required=false)
    private Other other;
}
```
这样就算bean为null，程序也能正常启动，但是需要注意空指针。
```java
public class Test{
    private Other other;

    /**
     * can't work
     * @param other
     */
    @Autowire(required=false)
    public Test(Other other) {
        this.other = other
    }
}
```
注意如果是通过构造器进行的bean引用，那么就算在构造器上申明了`@Autowire(required=false)`也没用。  
