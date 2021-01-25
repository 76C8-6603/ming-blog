---

    title: "Java注解说明"
    date: 2016-03-05
    tags: ["java"]

---

# 标准申明
```java
/**
 * Describes the Request-For-Enhancement(RFE) that led
 * to the presence of the annotated API element.
 */
public @interface RequestForEnhancement {
    int    id();
    String synopsis();
    String engineer() default "[unassigned]"; 
    String date();    default "[unimplemented]"; 
}
```
`RequestForEnhancement`注解包含的成员参数，需要通过方法来申明。如果有默认值，可以通过`default`来指定。  
成员方法的返回类型是有限制的，只能是：  
* 原始类型
* String
* Class
* enums
* 注解  
要么是上面五种类型，要么就是这五种类型的数组，其他的都不支持。  
  
# 唯一参数
```java
/**
 * Associates a copyright notice with the annotated API element.
 */
public @interface Copyright {
    String value();
}
```
如果注解只有一个参数，那么参数对应的方法名称应该是`value`。并且在调用该注解时，可以忽略参数名称和等于符号：  
```java
@Copyright("2002 Yoyodyne Propulsion Systems")
public class OscillationOverthruster { ... }
```

# @Target 
用来指定注解修饰的目标类型，比如在方法或者在类上等等。

# @Retention
该注解用来指定所修饰的注解要保留多长时间。  
注解`@Retention`只有一个成员`RetentionPolicy`枚举。
`RetentionPolicy`枚举有三个常量（按照顺序，保留时间递增）：  
* SOURCE
* CLASS
* RUNTIME

## SOURCE
代表这个注解是对编译器可见的，但是在.class文件和运行时不可用。编译器常用这类注解来检测异常和屏蔽警告。编译器在使用完这类注解后，会直接丢弃。  

## CLASS
代表这个注解会记录到.class文件中。但是虚拟机不需要在运行时保留它。这是默认策略。  

## RUNTIME
代表这个注解会记录到.class文件中，并且虚拟机在运行时也会保留它。这意味着可以通过反射读取。


> [annotation](https://docs.oracle.com/javase/1.5.0/docs/guide/language/annotations.html)  
> [RetentionPolicy](https://docs.oracle.com/javase/6/docs/api/java/lang/annotation/RetentionPolicy.html)