---

    title: "策略模式"
    date: 2017-01-07
    tags: ["design pattern"]

---

# 简介
策略模式：它定义了算法家族，分别封装起来，让他们之间可以互相替换，此模式让算法的变化，不会影响到使用算法的客户。  

所谓的策略模式跟简单工厂模式类似，只不过策略模式的`Context`类不管对象的生成，只封装了算法的执行类，给算法的执行提供了统一的入口。  
完全可以将工厂模式跟策略模式相结合，也就是说`Context`既负责对象生成，也负责调用方法的封装。
# 类图
![Strategy_Pattern_in_UML.png](/Strategy_Pattern_in_UML.png)
# 代码

```java
//StrategyExample test application

class StrategyExample {

    public static void main(String[] args) {

        Context context;

        // Three contexts following different strategies
        context = new Context(new FirstStrategy());
        context.execute();

        context = new Context(new SecondStrategy());
        context.execute();

        context = new Context(new ThirdStrategy());
        context.execute();

    }

}

// The classes that implement a concrete strategy should implement this

// The context class uses this to call the concrete strategy
interface Strategy {

    void execute();
    
}

// Implements the algorithm using the strategy interface
class FirstStrategy implements Strategy {

    public void execute() {
        System.out.println("Called FirstStrategy.execute()");
    }
    
}

class SecondStrategy implements Strategy {

    public void execute() {
        System.out.println("Called SecondStrategy.execute()");
    }
    
}

class ThirdStrategy implements Strategy {

    public void execute() {
        System.out.println("Called ThirdStrategy.execute()");
    }
    
}

// Configured with a ConcreteStrategy object and maintains a reference to a Strategy object
class Context {

    Strategy strategy;

    // Constructor
    public Context(Strategy strategy) {
        this.strategy = strategy;
    }

    public void execute() {
        this.strategy.execute();
    }

}
```