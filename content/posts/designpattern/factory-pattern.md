---

    title: "简单工厂，工厂，抽象工厂"
    date: 2017-01-07
    tags: ["design pattern"]
---
# 简单工厂模式
![简单工厂-01](/SimpleFactory.png)

# 工厂模式
> 定义一个用于创建对象的接口，让子类决定实例化哪个类。工厂方法使一个类的实例化延迟到其子类。  

相对于简单工厂模式一个工厂方法负责所有实例化，工厂模式要复杂一点，每一个实例化都对应了一个子类。  
工厂模式存在的意义是他符合了`开放封闭原则`，只对扩展开放，对修改封闭。相对简单工厂模式，新增一种实例化选项，就要修改原工厂代码，工厂模式不需要修改父类工厂，只需要添加一个新的子类工厂扩展就行。  

# 抽象工厂模式

> 抽象工厂模式，提供一个创建一系列相关或项目依赖对象的接口，而无需指定它们具体的类。  

相比`简单工厂模式`和`工厂模式`是对一个父子结构的抽象，`抽象工厂模式`针对的是多个父子结构，但是这些父子结构中有相同的分类。  

![抽象工厂](/Abstract_factory_UML.svg.png)

```java
public interface Button {}
public interface Border {}
//实现抽象类
public class MacButton implements Button {}
public class MacBorder implements Border {}

public class WinButton implements Button {}
public class WinBorder implements Border {}
//接着实现工厂
public class MacFactory {
	public static Button createButton() {
	    return new MacButton();
	}
	public static Border createBorder() {
	    return new MacBorder();
	}
}
public class WinFactory {
	public static Button createButton() {
	    return new WinButton();
	}
	public static Border createBorder() {
	    return new WinBorder();
	}
}
```