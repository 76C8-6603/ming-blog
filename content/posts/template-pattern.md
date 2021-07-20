---

    title: "模板模式"
    date: 2017-01-07
    tags: ["design pattern"]

---

# 简介
> 定义一个算法骨架，而将一些步骤延迟到子类当中。模板方法使得可以不改变一个算法的结构即可重定义该算法的某些特定步骤。
# 类图
![template pattern](/300px-Template_Method_UML.svg.png)
# 代码
抽象父类，定义算法结果和抽象步骤
```java
public interface AbstractClass{
    void primitiveOperation1();
    void primitiveOperation2();

    default void templateMethod() {
        primitiveOperation1();
        primitiveOperation2();
    }
}
```

具体实现子类，对父类的抽象方法进行重写
```java
public class ConcreteClassA implements AbstractClass{
    @Override
    public void primitiveOperation1() {
        System.out.println("operationA 1");
    }

    @Override
    public void primitiveOperation2() {
        System.out.println("operationA 2");
    }
}

public class ConcreteClassB implements AbstractClass{
    @Override
    public void primitiveOperation1() {
        System.out.println("operationB 1");
    }

    @Override
    public void primitiveOperation2() {
        System.out.println("operationB 2");
    }
}
```

