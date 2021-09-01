---

    title: "RequestParam.value() was empty on parameter 0"
    date: 2021-08-31
    tags: ["feign"]

---
### 背景
Feign项目启动时报错
```
RequestParam.value() was empty on parameter 0
```
### 代码
对应报错代码：
```java
@FeignClient("spring-cloud-eureka-client")
public interface GreetingClient {
    @RequestMapping("/greeting")
    String greeting(@RequestParam String name);
}
```

### 原因
Spring MVC和Spring Cloud feign都使用了同样的方式去查找参数名  
首先会通过反射查找，需要类以`-parameters`形式编译  
如果失败了，会通过debug info来查找。对于Spring MVC来说，这种方式是没有问题的，但是Feign无法通过这种方式获取，因为javac 编译器会忽略接口参数名的debug info，这就是根源所在。

> 参考[stackoverflow](https://stackoverflow.com/questions/44313482/feign-client-with-spring-boot-requestparam-value-was-empty-on-parameter-0)

### 解决方案
可以通过手动指定注解参数名称来解决问题：
```java
@FeignClient("spring-cloud-eureka-client")
public interface GreetingClient {
    @RequestMapping("/greeting")
    String greeting(@RequestParam("name") String name);
}
```


