---

    title: "职责链模式"
    date: 2017-01-09
    tags: ["design pattern"]

---
# 简介
> 使多个对象都有机会处理请求，从而避免请求的发送者和接受者之间的耦合关系。将这个对象连成一条链，并沿着这条链传递该请求，直到有一个对象处理它为止。  


# 类图
![chain pattern](/chain-pattern.png)

# 代码
抽象职责链
 ```java
public abstract class Handler {
    protected Handler successor;
    protected final String requestInfo = "处理类：%s，处理请求：%s";
    public void setSuccessor(Handler handler) {
        this.successor = handler;
    }

    public abstract void handlerRequest(int request) ;
}
```
具体职责链实现
```java
public class ConcreteHandler1 extends Handler{
    @Override
    public void handlerRequest(int request) {
        if (request >= 0 && request < 10) {
            System.out.println(String.format(requestInfo, this.getClass().getSimpleName(), request));
        } else if(successor != null) {
            successor.handlerRequest(request);
        }
    }
}
```
```java
public class ConcreteHandler2 extends Handler {

    @Override
    public void handlerRequest(int request) {
        if (request >= 10 && request < 20) {
            System.out.println(String.format(requestInfo, this.getClass().getSimpleName(), request));
        } else if (successor != null) {
            successor.handlerRequest(request);
        }
    }
}
```
```java
public class ConcreteHandler3 extends Handler {
    @Override
    public void handlerRequest(int request) {
        if (request >= 20 || request < 30) {
            System.out.println(String.format(requestInfo, this.getClass().getSimpleName(), request));
        } else if (successor != null) {
            successor.handlerRequest(request);
        }
    }
}
```
客户端代码
```java
public class Client {
    public static void main(String[] args) {
        final ConcreteHandler1 concreteHandler1 = new ConcreteHandler1();
        final ConcreteHandler2 concreteHandler2 = new ConcreteHandler2();
        final ConcreteHandler3 concreteHandler3 = new ConcreteHandler3();

        concreteHandler1.setSuccessor(concreteHandler2);
        concreteHandler2.setSuccessor(concreteHandler3);

        int[] requests = new int[]{5, 20, 10, 13, 18, 29};
        for (int request : requests) {
            concreteHandler1.handlerRequest(request);
        }
    }
}
```