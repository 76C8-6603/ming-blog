---

    title: "单例模式"
    date: 2017-01-09
    tags: ["design pattern"]

---
# 简介
> 保证一个类仅有一个实例，并提供一个访问它的全局访问点。  
> 通常我们可以让一个全局变量使得一个对象被访问，但它不能防止你实例化多个对象。一个最好的办法就是，让类自身负责保存它的唯一实例。这个类可以保证没有其他实例可以被创建，并且它可以提供一个访问该实例的方法。

# 代码
一般来说单例模式的实现有两种方式，一种是懒汉式，一种是饿汉式。  
但是这两种都有局限性，需要进一步优化，于是催生出`双重锁定`，`静态内部类`，和`枚举`等方法。  

## 饿汉式：  
饿汉式的优势是简单直接，并且线程安全，但是要考虑单例的体量和使用规模，避免资源浪费。
```java
public class HungrySingleton {
    private static HungrySingleton hungrySingleton = new HungrySingleton();

    private HungrySingleton() {}

    public static HungrySingleton getInstance() {
        return hungrySingleton;
    }
}
```


## 懒汉式：  
懒汉式的优势很明显，因为他的惰性，在没有调用获取实例方法前，单点实例都不会被初始化。但是他并不是线程安全的，因为if和new的操作并不是一个原子性的操作，当多个线程同时进入判断时，就会创建多个实例。
```java
public  class LazySingleton {
    private static LazySingleton lazySingleton = null;

    private LazySingleton() {}

    public static LazySingleton getInstance() {
        if (lazySingleton == null) {
            lazySingleton = new LazySingleton();
        }
        return lazySingleton;
    }
}
```
当然可以通过synchronized同步获取实例方法：
```java
public  class LazySingleton {
    private static LazySingleton lazySingleton = null;

    private LazySingleton() {}

    public static synchronized LazySingleton getInstance() {
        if (lazySingleton == null) {
            lazySingleton = new LazySingleton();
        }
        return lazySingleton;
    }
}
```

## 双重锁定
synchronized虽然可以实现线程安全的懒汉式单例，但是这样性能会降低。这就有了双重锁定的优化：  
```java
public  class LazySingleton {
    private static LazySingleton lazySingleton = null;

    private LazySingleton() {}

    public static LazySingleton getInstance() {
        if (lazySingleton == null) {
            synchronized (LazySingleton.class) {
                if (lazySingleton == null) {
                    lazySingleton = new LazySingleton();
                }
            }
        }
        return lazySingleton;
    }
}
```
这样就让大多数非并发和单例对象已经不为null的情况能够非阻塞的获取实例。  
但为什么要多次验证了？因为第一个是用来保证实例不为null的情况下不会阻塞，而第二个判断是为了保证多个线程同时进入第一层判断时，只有一个线程能新建单例对象。    

按照双重锁定的写法这样既保证了性能又保证了线程安全，但是对于java来说这还不够，因为指令重排序的存在。  
指令重排序会让JVM不按照既定顺序执行指令，这有助于优化指令的执行效率，但是也会导致并发问题。   
在这里，正常的顺序应该是，单例对象分配内存初始化变量，执行构造函数，然后赋值给`lazySingleton`引用，但是因为指令重排序的原因，可能会出现初始化后直接赋值给引用，还没有执行构造函数的情况。虽然这在单线程的情况下没有任何问题，但是多线程下可能刚好在这个时候，另外一个线程进入调用了getInstance方法，这样就会导致这个线程获取的对象可能还不完整。  

好在JDK1.5之后添加了volatile关键字。volatile关键字可以保证指令的顺序性和修饰成员变量的可见性。  

```java
public class LazySingleton {
    private static volatile LazySingleton lazySingleton = null;

    private LazySingleton() {}

    public static LazySingleton getInstance() {
        if (lazySingleton == null) {
            synchronized (LazySingleton.class) {
                if (lazySingleton == null) {
                    lazySingleton = new LazySingleton();
                }
            }
        }
        return lazySingleton;
    }
}
```

## 静态内部类
```java
public class Singleton {

    private Singleton() {}

    private static class SingletonHolder{
        public static Singleton singleton = new Singleton();
    }

    public static Singleton getInstance() {
        return SingletonHolder.singleton;
    }
}
```
静态内部类利用了java的类加载机制，内部类只要还没使用，JVM就不会去加载内部类及其中的单例对象，从而实现了懒汉式的延迟加载，同样也保证了线程安全。  

## 枚举类
```java
public enum MySingleton {
  INSTANCE;   
}
```
获取单例
```java
public static void main(String[] args) {
    System.out.println(MySingleton.INSTANCE);
}
```
通过枚举实现的单例，非常简单，其实底层跟饿汉式的实现几乎是一样的。但是通过枚举可以保证单实例不被反序列化和反射攻击，并且枚举本身也很好的实现了序列化，不需要对单例的序列化问题做额外的处理。  
存在的问题跟饿汉式一样，没有延迟加载的特性。  



