---
    title: "Java final成员变量初始化"
    date: 2016-01-08
    tags: ["java"]
    
---

```java
public class Test{
    /**
    ** 一种是直接指定初始值
    **/
    final String msg = "";

    /**
    ** 另一种是不指定初始值，在构造方法里面指定
    ** 但不允许无参构造的存在，并且每一个构造方法都要对该变量赋值
    **/
    final String msg1;
    
    public Test(String msg1){
        this.msg1 = msg1;    
    }

}
```