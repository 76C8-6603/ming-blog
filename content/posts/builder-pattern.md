---

    title: "建造者模式"
    date: 2017-01-08
    tags: ["design pattern"]

---
# 简介
> 将一个复杂对象的构建与它的表示分离，使得同样的构建过程可以创建不同的表示。

# 类图
![builder pattern](/structure.png)

# 代码
产品类，建造者的生成目标
```java
public class Product {
    private List<String> parts = new ArrayList<>();

    public void add(String part) {
        parts.add(part);
    }

    public void show() {
        System.out.println(Arrays.toString(parts.toArray()));
    }
}
```

建造者类，和其实现
```java
public interface Builder {
    void buildPartA();

    void buildPartB();

    Product getResult();
}

public class ConcreteBuilder1 implements Builder{

    private Product product = new Product();

    @Override
    public void buildPartA() {
        product.add("builder 1 part A");
    }

    @Override
    public void buildPartB() {
        product.add("builder 1 part B");

    }

    @Override
    public Product getResult() {
        return product;
    }
}

public class ConcreteBuilder2 implements Builder {

    private Product product = new Product();

    @Override
    public void buildPartA() {
        product.add("builder 2 part A");
    }

    @Override
    public void buildPartB() {
        product.add("builder 2 part B");

    }

    @Override
    public Product getResult() {
        return product;
    }
}
```
指挥者类，封装构造器的构造流程。  
```java
public class Director {
    public void construct(Builder builder) {
        builder.buildPartA();
        builder.buildPartB();
    }
}
```

执行类
```java
public class Test {
    public static void main(String[] args) {
        final Director director = new Director();

        final ConcreteBuilder1 concreteBuilder1 = new ConcreteBuilder1();
        director.construct(concreteBuilder1);
        final Product result1 = concreteBuilder1.getResult();
        result1.show();

        final ConcreteBuilder2 concreteBuilder2 = new ConcreteBuilder2();
        director.construct(concreteBuilder2);
        final Product result2 = concreteBuilder2.getResult();
        result2.show();
    }
}
```

