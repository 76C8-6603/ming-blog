---

    title: "适配器模式"
    date: 2017-01-08
    tags: ["design pattern"]

---

# 简介
> 将一个类的接口转换成客户希望的另外一个接口。Adapter模式使得原本由于接口不兼容而不能一起工作的那些类可以一起工作。  

适配器有两种类型，一种是类适配器，一种是对象适配器。类适配器是通过多重继承对一个接口与另外一个接口进行匹配，但是java只支持单继承，因此这里讨论的都是对象适配器。  
# 类图
![adapter pattern](/300px-ClassAdapter.png)
# 代码
标准调用
```java
public class Target {
    public void request() {
        System.out.println("normal request");
    }
}
```

非标准调用
```java
public class Adaptee {
    public void specialRequest() {
        System.out.println("special request");
    }
}
```

适配器
```java
public class Adapter extends Target {

    private Adaptee adaptee = new Adaptee();

    @Override
    public void request() {
        adaptee.specialRequest();
    }
}
```

客户端代码
```java
public class Test {
    public static void main(String[] args) {
        Target target = new Adapter();
        target.request();
    }
}
```


