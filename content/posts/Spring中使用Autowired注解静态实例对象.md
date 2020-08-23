---
    title: "[转]Spring中使用@Autowired注解静态实例对象"
    date: 2019-07-24
    tags: ["spring"]
    
---

问题
最近项目小组在重新规划工程的业务缓存，其中涉及到部分代码重构，过程中发现有些工具类中的静态方法需要依赖别的对象实例（该实例已配置在xml成Spring bean，非静态可以用@Autowired加载正常使用），而我们知道，类加载后静态成员是在内存的共享区，静态方法里面的变量必然要使用静态成员变量，这就有了如下代码：

```java
@Component
public class TestClass {

    @Autowired
    private static AutowiredTypeComponent component;

    // 调用静态组件的方法
    public static void testMethod() {
        component.callTestMethod();
    }

}
```
 

编译正常，但运行时报java.lang.NullPointerException: null异常，显然在调用testMethod()方法时，component变量还没被初始化，报NPE。

原因
所以，在Springframework里，我们是不能@Autowired一个静态变量，使之成为一个Spring bean的。为什么？其实很简单，因为当类加载器加载静态变量时，Spring上下文尚未加载。所以类加载器不会在bean中正确注入静态类，并且会失败。

解决方案
方式一
将@Autowired 注解到类的构造函数上。很好理解，Spring扫描到AutowiredTypeComponent的bean，然后赋给静态变量component。示例如下：

```java
@Component
public class TestClass {

    private static AutowiredTypeComponent component;

    @Autowired
    public TestClass(AutowiredTypeComponent component) {
        TestClass.component = component;
    }

    // 调用静态组件的方法
    public static void testMethod() {
        component.callTestMethod();
    }

}
```
 

方式二
给静态组件加setter方法，并在这个方法上加上@Autowired。Spring能扫描到AutowiredTypeComponent的bean，然后通过setter方法注入。示例如下：

```java
@Component
public class TestClass {

    private static AutowiredTypeComponent component;

    @Autowired
    public void setComponent(AutowiredTypeComponent component){
        TestClass.component = component;
    }

    // 调用静态组件的方法
    public static void testMethod() {
        component.callTestMethod();
    }

}
```
 

方式三
定义一个静态组件，定义一个非静态组件并加上@Autowired注解，再定义一个初始化组件的方法并加上@PostConstruct注解。这个注解是JavaEE引入的，作用于servlet生命周期的注解，你只需要知道，用它注解的方法在构造函数之后就会被调用。示例如下：

```java
@Component
public class TestClass {

    private static AutowiredTypeComponent component;

    @Autowired
    private AutowiredTypeComponent autowiredComponent;

    @PostConstruct
    private void beforeInit() {
        component = this.autowiredComponent;
    }

    // 调用静态组件的方法
    public static void testMethod() {
        component.callTestMethod();
    }

}
```
 

方式四
直接用Spring框架工具类获取bean，定义成局部变量使用。但有弊端：如果该类中有多个静态方法多次用到这个组件则每次都要这样获取，个人不推荐这种方式。示例如下：

```java
public class TestClass {
    // 调用静态组件的方法
    public static void testMethod() {
        AutowiredTypeComponent component = SpringApplicationContextUtil.getBean("component");
        component.callTestMethod();
    }
}
```
 


原文：https://blog.csdn.net/RogueFist/article/details/79575665 