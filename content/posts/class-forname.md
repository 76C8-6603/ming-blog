---
    title: "[转]Class.forName()用法详解"
    date: 2017-11-15
    tags: ["java"]
    
---

转自:http://blog.csdn.net/kaiwii/article/details/7405761  
主要功能  
Class.forName(xxx.xx.xx)返回的是一个类  
Class.forName(xxx.xx.xx)的作用是要求JVM查找并加载指定的类，  
也就是说JVM会执行该类的静态代码段  
下面，通过解答以下三个问题的来详细讲解下Class.forName()的用法。  

### 一.什么时候用Class.forName()？
先来个热身，给你一个字符串变量，它代表一个类的包名和类名，你怎么实例化它？你第一想到的肯定是new,但是注意一点：  
```java
A a = (A)Class.forName(“pacage.A”).newInstance();
```
这和你 A a = new A()； 是一样的效果。  

现在言归正传。  
动态加载和创建Class 对象，比如想根据用户输入的字符串来创建对象时需要用到：  
```java
String str = “用户输入的字符串” ;
Class t = Class.forName(str);
t.newInstance();
```

在初始化一个类，生成一个实例的时候，newInstance()方法和new关键字除了一个是方法，一个是关键字外，最主要有什么区别？它们的区别在于创建对象的方式不一样，前者是使用类加载机制，后者是创建一个新类。那么为什么会有两种创建对象方式？这主要考虑到软件的可伸缩、可扩展和可重用等软件设计思想。

Java中工厂模式经常使用newInstance()方法来创建对象，因此从为什么要使用工厂模式上可以找到具体答案。 例如：  
```java
class c = Class.forName(“Example”);
factory = (ExampleInterface)c.newInstance();
```

其中ExampleInterface是Example的接口，可以写成如下形式：
```java
String className = “Example”;
class c = Class.forName(className);
factory = (ExampleInterface)c.newInstance();
```

进一步可以写成如下形式：
```java
String className = readfromXMlConfig;//从xml 配置文件中获得字符串
class c = Class.forName(className);
factory = (ExampleInterface)c.newInstance();
```

上面代码已经不存在Example的类名称，它的优点是，无论Example类怎么变化，上述代码不变，甚至可以更换Example的兄弟类Example2 , Example3 , Example4……，只要他们继承ExampleInterface就可以。

从JVM的角度看，我们使用关键字new创建一个类的时候，这个类可以没有被加载。但是使用newInstance()方法的时候，就必须保证：  
1、这个类已经加载；  
2、这个类已经连接了。  

而完成上面两个步骤的正是Class的静态方法forName()所完成的，这个静态方法调用了启动类加载器，即加载 java API的那个加载器。

现在可以看出，newInstance()实际上是把new这个方式分解为两步，即首先调用Class加载方法加载某个类，然后实例化。 这样分步的好处是显而易见的。我们可以在调用class的静态加载方法forName时获得更好的灵活性，提供给了一种降耦的手段。

### 二.new 和Class.forName（）有什么区别？
其实上面已经说到一些了，这里来做个总结：  
首先，newInstance( )是一个方法，而new是一个关键字；  
其次，Class下的newInstance()的使用有局限，因为它生成对象只能调用无参的构造函数，而使用 new关键字生成对象没有这个限制。
简言之：  
* newInstance(): 弱类型,低效率,只能调用无参构造。
* new: 强类型,相对高效,能调用任何public构造。
* Class.forName(“”)返回的是类。
* Class.forName(“”).newInstance()返回的是object 。
### 三.为什么在加载数据库驱动包的时候有用的是Class.forName( )，却没有调用newInstance( )？
在Java开发特别是数据库开发中，经常会用到Class.forName( )这个方法。   
通过查询Java Documentation我们会发现使用Class.forName( )静态方法的目的是为了动态加载类。  
通常编码过程中，在加载完成后，一般还要调用Class下的newInstance( )静态方法来实例化对象以便操作。因此，单单使用Class.forName( )是动态加载类是没有用的，其最终目的是为了实例化对象。  

有数据库开发经验朋友会发现，为什么在我们加载数据库驱动包的时候有的却没有调用newInstance( )方法呢？  
即有的jdbc连接数据库的写法里是Class.forName(xxx.xx.xx);而有一 些：Class.forName(xxx.xx.xx).newInstance()，为什么会有这两种写法呢？  
刚才提到，Class.forName(“”);的作用是要求JVM查找并加载指定的类，首先要明白，java里面任何class都要装载在虚拟机上才能运行，而静态代码是和class绑定的，class装载成功就表示执行了你的静态代码了，而且以后不会再走这段静态代码了。  
而我们前面也说了，Class.forName(xxx.xx.xx)的作用就是要求JVM查找并加载指定的类，如果在类中有静态初始化器的话，JVM必然会执行该类的静态代码段。  
而在JDBC规范中明确要求这个Driver类必须向DriverManager注册自己，即任何一个JDBC Driver的 Driver类的代码都必须类似如下：  

```java
public class MyJDBCDriver implements Driver {
    static {
        DriverManager.registerDriver(new MyJDBCDriver());
    }
}    
```

既然在静态初始化器的中已经进行了注册，所以我们在使用JDBC时只需要Class.forName(XXX.XXX);就可以了。

相关英文参考文献如下：  
we just want to load the driver to jvm only, but not need to user the instance of driver,  
so call Class.forName(xxx.xx.xx) is enough, if you call Class.forName(xxx.xx.xx).newInstance(),  
the result will same as calling Class.forName(xxx.xx.xx),  
because Class.forName(xxx.xx.xx).newInstance() will load driver first,  
and then create instance, but the instacne you will never use in usual,  
so you need not to create it.