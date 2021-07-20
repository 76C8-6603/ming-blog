---

    title: "外观模式/门面模式"
    date: 2017-01-08
    tags: ["design pattern"]

---

# 简介
外观模式又叫门面模式  
> 是为子系统中的一组接口提供一个一致的界面，此模式定义了一个高层接口，这个借口使得这一子系统更加容易使用。  

外观模式的使用场景
1. 首先在设计初期阶段，应该有意识的将不同的两个层分离，一般来说就是三层架构，数据访问层，业务逻辑层，和展示层。将不同层的代码通过门面模式封装，能大大降低耦合，简化调用。  
2. 在开发阶段，不断的重构也会产生很多小的类，通过门面模式提供一个统一的访问接口，减少耦合。  
3. 在维护一个较老的系统时，也可以通过门面模式组合历史代码，提供最新的调用接口格式规范。
# 类图
![facade pattern](/FacadeDesignPattern.png)
# 代码
```java
public class SubSystemOne {
    public void methodOne() {
        System.out.println("Method One");
    }
}

public class SubSystemTwo {
    public void methodTwo() {
        System.out.println("Method Two");

    }
}
```

```java
public class Facade {
    private SubSystemOne subSystemOne;
    private SubSystemTwo subSystemTwo;

    public Facade() {
        this.subSystemOne = new SubSystemOne();
        this.subSystemTwo = new SubSystemTwo();
    }

    public void methodOne() {
        subSystemOne.methodOne();
        subSystemOne.methodOne();
    }

    public void methodAll() {
        subSystemOne.methodOne();
        subSystemTwo.methodTwo();
    }
}
```
