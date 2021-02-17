---
    title: "Spring切面编程"
    date: 2017-06-06
    tags: ["spring"]
    
---

# 1.切面编程核心概念
> 切面编程Aspect-oriented Programming (AOP)  

AOP只是一个概念，跟Spring是独立关系  
最典型的AOP实现框架`AspectJ`，是一个十分成熟的框架，Spring AOP相比只是基于它做了一些功能的强化，是互补关系
  
几个核心的参数概念（基于AspectJ）
* Aspect: 切面编程的核心是切面，因此首先需要一个切面类(`@Aspect`注解修饰的类)
* Join point: 代表需要切面处理的方法（Spring AOP只针对方法，因此以下简称*目标方法*）
* Advice: 切面类需要在*目标方法*运行的哪个阶段进行处理，比如`before(调用之前)`，`after(调用之后)`，`around(前后都进行处理)`
* Pointcut: 当前的切面类需要监听的*目标方法*有什么特征，或者说切面类要怎样找到需要处理的*目标方法*，比如被注解`@Log`修饰的方法
* Introduction: 申明一个额外的方法或者字段去代表*目标方法*的对象，意思就是你可以给*目标方法*所在类追加一个父类（接口），并指定一个实现去代表它（AspectJ称为inter-type declaration）  
* Target object: *目标方法*所在的对象，也叫作`advised object`。但是Spring AOP是通过运行时代理实现的，意思就是这个对象是一个代理类的对象  

完整的Advice类型包括：
* Before advice: 在*目标方法*之前
* After returning advice: 在*目标方法*return之后，如果*目标方法*没有抛异常的话
* After throwing advice: 在*目标方法*抛完异常之后
* After (finally) advice: 相当于finally
* Around advice: 在方法执行前后做处理，可以处理参数，捕获异常，修改返回结果  

建议使用最小范围的Advice，比如说仅需要处理返回结果，只需要设定类型为`After returning advice`即可  
能不使用`Around advice`的时候尽量不使用，因为它需要你手动去调用*目标方法*(通过动态代理)，尽可能地减少出错  
Spring AOP默认使用标准的`JDK dynamic proxies`作为AOP的代理，就是切面类中调用*目标方法*的过程。  

# 2.基于AspectJ的Spring AOP实例

## 2.1 配置类

注解`EnableAspectJAutoProxy`，让Spring在*目标方法*被执行时，自动拦截方法调用并生成代理类
```java
@Configuration
@EnableAspectJAutoProxy
public class AppConfig {
}
```

## 2.2 切面类声明
注意切面类的方法不能作为*目标方法*被拦截
```java
package org.xyz;
import org.aspectj.lang.annotation.Aspect;

@Component
@Aspect
public class NotVeryUsefulAspect {

}
```

## 2.3 切面方法特征申明(Pointcut)
Spring AOP只支持方法执行的切入点，所以Pointcut就是在申明怎么匹配目标*目标方法*  

一个Pointcut的声明有两个部分
* 新建一个方法，任意参数，任意名称，返回值必须是void
* 新建的方法需要一个`@Pointcut`注解，这个注解和他的参数叫做pointcut表达式  

下面是一个例子，代表pointcut的名字是`anyOldTransfer`，匹配的*目标方法*是任何方法名叫做`transfer`的
```java
@Pointcut("execution(* transfer(..))")
private void andOldTransfer(){}
```
注解`Pointcut`的value就是`AspectJ5`的pointcut表达式  

### 2.3.1 支持的Pointcut标识符
在pointcut表达式中，Spring AOP支持下列的AspectJ pointcut 标识符(PCD)：
* `execution`: 用于直接匹配*目标方法*。对Spring AOP来说，这是主要的pointcut指示符
* `within`: 限制*目标方法*是在匹配的类型中申明
* `this`: 限制*目标方法*，其bean引用(Spring AOP代理)是给定类型的实例
* `target`: 限制*目标方法*，其目标对象(正在代理的应用程序对象)是给定类型的实例
* `args`: 限制*目标方法*，其参数是给定类型的实例
* `@target`: 限制*目标方法*，其类有指定类型的注解
* `@args`: 限制*目标方法*，其实际传输的参数，每个参数的类型都有给定的注解
* `@within`: 限制*目标方法*，其所在类型有给定的注解
* `@annotation`: 限制*目标方法*有给定注解  

在AspectJ中，因为Aspect是一个基于类型的语法，this和target都指向同一个对象。  
但在SpringAOP中，this和target是有区别的，Spring AOP是基于代理的系统，this代表的是代理对象，target代表的才是*目标方法*所在的对象

> Spring不支持以下AspectJ的pointcut标识符：  
>`call, get, set, preinitialization, staticinitialization, initialization, handler, adviceexecution, withincode, cflow, cflowbelow, if, @this, and @withincode`  
>如果使用这些pointcut标识符会抛出`IllegalArgumentException`  

> 因为Spring AOP以代理为基础的特性，是不会拦截在*目标方法*所在类中的调用的，换句话说*目标方法*所在类的其他方法中调用了*目标方法*是不会触发拦截的    
> 这个特性是由Spring AOP默认使用的`JDK proxies`造成的，可以通过替换`Spring's proxy-based AOP framework`为[Spring-driven native AspectJ weaving](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/core.html#aop-aj-ltw) 来解决，但是需要对`waving`有一定熟练度  

Spring AOP支持一个额外的PCD，叫做`bean`。这个标识符可以让你限制*目标方法*去匹配一个或多个指定的Spring bean(多个通过通配符)  
```java
bean(idOrNameOfBean)
```
`idOrNameOfBean`可以是任何Spring bean的名称。如果你确定了多个bean名称的规则，可以也只能用`*`号去写PCD表达式来选择他们  
当`bean`需要和其他的PCD一起使用的时候，同样可以使用`&&`(and)，`!`(negation),`||`(or)来连接

### 2.3.2 组合pointcut表达式
你可以组合pointcut表达式通过使用`&&`，`||`和`!`  
```java
@Pointcut("execution(public * *(..))")
private void anyPublicOperation(){}

@Pointcut("within(com.xyz.myapp.trading..*)")
private void inTrading(){}

@Pointcut("anyPublicOperation() && inTrading()")
private void tradingOperation(){}
```
对上面的三个pointcut逐个解析
1. `anyPublicOperation` 匹配任何*目标方法*是public的
2. `inTrading` 匹配任何*目标方法*在`trading`模块路径下
3. `tradingOperation` 任何*目标方法*是public，并且在`trading`模块下

从小的命名组件完成了一个复杂的pointcut表达式的构建，这是一个最好的实现方式，正如上面的实例。  
当通过名字引用pointcut，跟一般java的可见规则一样(private,protected,public)，意味着你可以引用其他类的pointcut，只要对应pointcut的类修饰符可见。
pointcut的可见性不影响切面的匹配，只影响pointcut表达式的引用

### 2.3.3 分享共用的Pointcut定义
在开发中有很多切面是经常使用到的，推荐定义一个`CommonPointcuts`切面类来定义共用的pointcut表达式  
典型的类似下边的这个例子：
```java
package com.xyz.myapp;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;

@Aspect
public class CommonPointcuts {

    /**
     * 在web层的切面，任何在web目录以及子目录类中定义的方法
     */
    @Pointcut("within(com.xyz.myapp.web..*)")
    public void inWebLayer() {}

    /**
     * service层的切面，任何在service目录以及子目录类中定义的方法
     */
    @Pointcut("within(com.xyz.myapp.service..*)")
    public void inServiceLayer() {}

    /**
     * dao层的切面，任何在dao目录以及子目录类中定义的方法
     */
    @Pointcut("within(com.xyz.myapp.dao..*)")
    public void inDataAccessLayer() {}

    /**
     * 业务Service切面，任何在service接口中定义的方法,假定接口在"service"package中，并且子包中有其实现类
     *
     * 也可以使用bean(*Service)，但是要确保Service的命名规则
     */
    @Pointcut("execution(* com.xyz.myapp..service.*.*(..))")
    public void businessService() {}

    /**
     * 任何在dao接口中定义的方法，假定接口在"dao"package中，并且子包有其实现类
     */
    @Pointcut("execution(* com.xyz.myapp.dao.*.*(..))")
    public void dataAccessOperation() {}

}
```
你可以引用这些pointcut定义，在任何你需要他们的地方。举个例子，给所有service层都加上事务，你可以这样写：
```xml
<aop:config>
    <aop:advisor
        pointcut="com.xyz.myapp.CommonPointcuts.businessService()"
        advice-ref="tx-advice"/>
</aop:config>

<tx:advice id="tx-advice">
    <tx:attributes>
        <tx:method name="*" propagation="REQUIRED"/>
    </tx:attributes>
</tx:advice>
```
关于具体的\<aop:config>和\<aop:advisor>元素使用方式可以参考 [Schema-based AOP Support](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/core.html#aop-schema)  
关于事务元素的使用可以参考 [Transaction Management](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/data-access.html#transaction)  

### 2.3.4 实例
Spring AOP 的用户最经常使用的pointcut标识符是`execution`，`execution`表达式的格式如下：
```
 execution(modifiers-pattern? ret-type-pattern declaring-type-pattern?name-pattern(param-pattern)
                throws-pattern?)
```
* 以上表达式中，除了`ret-type-pattern`，`name-pattern`和`param-pattern`是必须的，其他的都是可选参数  
* `ret-type-pattern`指代返回类型
    * `*`号是最常用到的，代表可以返回任何类型
    * 一个完全限定的类型名称，只有在方法返回指定类型的时候才会匹配  


* `name-pattern` 指代方法名称
    * 你可以使用`*`号来代替部分或者全部方法名
    * 如果你指定了`declaring-type-pattern`，用`.`号连接`name-component`  


* `param-pattern` 指代方法参数
    * `()`代表方法没有任何参数
    * `(..)`代表方法可能没有参数，也可能有任意数量任意类型的参数
    * `(*)` 代表方法有一个任意类型的参数
    * `(*,String)` 代表方法有两个参数，一个是任意类型，一个必须是String  
    
完整的AspectJ pointcut表达式语法结构可以参考[Language Semantics](https://www.eclipse.org/aspectj/doc/released/progguide/semantics-pointcuts.html)  
一下的实例展示了经常使用到的pointcut表达式：
* 任何执行的public方法
>   execution(public * *(..))

* 任何执行的方法是以set开头的
>   execution(* set*(..))

* 任何执行的方法是AccountService中定义的
>   execution(* com.xyz.service.AccountService.*(..))

* 任何执行的方法是定义在service包中的
>   execution(* com.xyz.service.*.*(..))

* 任何执行的方法是定义在service包或者其子包中的
>   execution(* com.xyz.service..*.*(..))

* 任何在service包下的方法
>   within(com.xyz.service.*)

* 任何在service包或其子包下的方法
>   within(com.xyz.service..*)

* 任何方法的代理是实现`AccountService`接口的
>   this(com.xyz.service.AccountService)  
>   一般用于绑定结构，具体用法在后面会提到  

* 任何方法的目标对象是实现`AccountService`接口的
>   target(com.xyz.service.AccountService)   
>   一般用于绑定结构，具体用法在后面会提到

* 任何执行的方法有一个参数，并且这个参数在运行时是通过`Serializable`传递的
>   args(java.io.Serializable)  
>   一般用于绑定接口，具体用法在后面会提到  
>   注意这里的参数匹配跟`execution(* *(java.io.Serializable))`是不同的  
>   args代表参数在运行时是以`Serializable`传递的  
>   execution代表参数必须是`Serializable`类型  

* 任何方法的目标对象有`@Transactional`注解
>   @target(org.springframework.transaction.annotation.Transactional)  
>   你同样可以把他用在绑定结构，具体用法在后面会提到

* 任何方法的目标对象的申明类型有`@Transactional`注解
>   @within(org.springframework.transaction.annotation.Transactional)  
>   你同样可以把他用在绑定结构，具体用法在后面会提到

* 任何方法上有`@Transactional`注解
>   @annotation(org.springframework.transaction.annotation.Transactional)  
>   你同样可以把他用在绑定结构，具体用法在后面会提到

* 任何方法只有一个参数，并且该参数在运行时传递有`@Classified`注解
>   @args(com.xyz.security.Classified)  
>   你同样可以把他用在绑定结构，具体用法在后面会提到

* 任何方法所属的Spring bean的名称是`tradeService`
>   bean(tradeService)

* 任何方法所属的Spring bean的名称是以`Service`结尾
>   bean(*Service)

### 2.3.5 写好pointcuts表达式
AspectJ不会直接采用你写的pointcut表达式，进行分析校验后，你的表达式会被重写  
关于表达式的顺序，AspectJ也会重排，意味着不需要担心你的表达式写法会影响匹配效率  

但是你直接选用的pointcut标识符还是会对匹配效率造成影响，原则上应该选用搜索范围更小的定义    
AspectJ的标识符可以分为三类：类型，范围，和上下文：(以下标识符包括Spring不支持的)  

* 类型：指定类型的连接点：`execution`,`get`,`set`,`call`,和`withcode`
* 范围：指定范围内的连接点：`within`和`withcode`
* 上下文：指定上下文：`this`,`target`,和`@annotation`  
  
一个好的pointcut表达式至少要包含`类型`和`范围`两个类型  
如果只有`类型`和`上下文`，会影响性能，因为需要一些额外的处理和分析  
但是`范围`不同，他的匹配速度非常快，一个好的pointcut表达式应该尽可能的包含一个

## 2.4 申明Advice
Advice需要关联一个pointcut表达式，并申明在匹配的pointcut之前(before)，之后(after)，或者前后(around)运行  
引用pointcut表达式可简单引用已命名的pointcut表达式，或者就地申明pointcut表达式  
### 2.4.1 Before Advice
你可以在一个切面类中申明`before advice`通过使用`@Before`注解:
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

@Aspect
public class BeforeExample {

    @Before("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
    public void doAccessCheck() {
        // ...
    }

}
```
如果我们不引用已声明的pointcut，可以直接就地申明：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;

@Aspect
public class BeforeExample {

    @Before("execution(* com.xyz.myapp.dao.*.*(..))")
    public void doAccessCheck() {
        // ...
    }

}
```

### 2.4.2 After Returning Advice
`After Returning Advice`在方法正常`return`后运行。  
你可以申明它通过使用`@AfterReturning`注解：  
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterReturning;

@Aspect
public class AfterReturningExample {

    @AfterReturning("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
    public void doAccessCheck() {
        // ...
    }

}
```

> 你可以拥有多个`advice`，在同一个切面类中  

有些时候，你需要在advice方法中访问*目标方法*的返回值。你可以使用`@AfterReturning`的参数结构去绑定返回参数：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterReturning;

@Aspect
public class AfterReturningExample {

    @AfterReturning(
        pointcut="com.xyz.myapp.CommonPointcuts.dataAccessOperation()",
        returning="retVal")
    public void doAccessCheck(Object retVal) {
        // ...
    }

}
```
`returning`参数所用的名字，必须跟advice方法的参数名相同  
并且返回值的类型也必须匹配(这里用的Object，可匹配所有返回值)  
  
注意想通过`after returning advice`返回一个完全不同的引用是不可能的  
             
### 2.4.3 After Throwing Advice
`After Throwing Advice`当`目标方法`是因为抛出异常退出的时候执行。
可以通过`@AfterThrowing`注解来实现：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterThrowing;

@Aspect
public class AfterThrowingExample {

    @AfterThrowing("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
    public void doRecoveryActions() {
        // ...
    }

}
```
在通常使用情况下，你可能需要在指定异常的时候运行Advice，或者获取方法抛出的异常（想获得异常，又不想限制，使用`Throwable`）  
你可以使用`@AfterThrowing`的属性`throwing`来实现：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.AfterThrowing;

@Aspect
public class AfterThrowingExample {

    @AfterThrowing(
        pointcut="com.xyz.myapp.CommonPointcuts.dataAccessOperation()",
        throwing="ex")
    public void doRecoveryActions(DataAccessException ex) {
        // ...
    }

}
```

同样`throwing`中的名字必须跟advice方法的参数名称相同  
当然也有类型限制，advice方法的参数类型，必须跟*目标方法*抛出的异常类型相同

### 2.4.4 After (Finally) Advice
`After (Finally) Advice`是在*目标方法*执行退出后运行  
它通过注解`@After`来实现，用该注解的时候，你需要同时处理正常返回现象和异常退出现象  
这个Advice通常用来处理资源释放问题或者其他相似的情形：
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.After;

@Aspect
public class AfterFinallyExample {

    @After("com.xyz.myapp.CommonPointcuts.dataAccessOperation()")
    public void doReleaseLock() {
        // ...
    }

}
```

### 2.4.5 Around Advice
`Around Advice`是最后一个advice，也是最强大的一个。你可以在方法执行前，执行后做处理，甚至可以决定什么时候运行，怎样运行，是否运行*目标方法*  
它经常使用的场景是在方法运行前后有状态信息需要分享的，比如方法的运行时间等等  
在选择Advice的时候，始终使用功能最弱的那个，比如能用Before，就不用Around  

`Around Advice`通过注解`@Around`来申明。advice方法的第一个参数类型必须是`ProceedingJoinPoint`  
在advice方法中，通过调用第一个参数的`proceed()`方法，可以执行*目标方法*  
`proceed`可以传递一个`Object[]`参数，这个数组，是*目标方法*所需要的所有参数    
如何使用`Around Advice`？下面是一个例子：  
```java
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.ProceedingJoinPoint;

@Aspect
public class AroundExample {

    @Around("com.xyz.myapp.CommonPointcuts.businessService()")
    public Object doBasicProfiling(ProceedingJoinPoint pjp) throws Throwable {
        // start stopwatch
        Object retVal = pjp.proceed();
        // stop stopwatch
        return retVal;
    }

}
```
around advice 的返回值就是方法调用者看到的返回值。举个例子，一个简单的缓存切面，如果缓存里面有直接从缓存返回，如果缓存里面没有再调用`proceed()`方法。  
注意`proceed`有可能调用一次，或者多次，甚至不调用，这都是合法的  

### 2.4.6 advice参数 

#### 访问当前的 `JoinPoint`
任何的advice方法都可以申明`JoinPoint`作为第一个参数（除了`around`例外，不过它的第一个参数`ProceedingJoinPoint`，也是`JoinPoint`的子类)  
`JoinPoint`提供了一些很有用的方法：
* `getArgs()`：返回方法参数
* `getThis()`：返回代理对象
* `getTarget()`：返回目标对象
* `getSignature()`：返回方法的描述
* `toString()`：打印方法有用的描述  

完整API参考[javadoc](https://www.eclipse.org/aspectj/doc/released/runtime-api/org/aspectj/lang/JoinPoint.html)

#### 给Advice传递参数
我们已经看过怎样绑定返回值和异常值（通过使用`after returning`和`after throwing`advice)。那么参数值怎么绑定了，可以使用`args`表达式  
如果在args表达式里使用对应的advice方法的参数名代替类型名，当advice被调用时对应的参数就会被指定类型的原方法参数替换。  
举个例子，假如你的*目标方法*第一个参数是一个类型为`Account`的对象，你需要访问这个account参数在advice的方法体中，你可以像下面这样写：
```java
@Before("com.xyz.myapp.CommonPointcuts.dataAccessOperation() && args(account,..)")
public void validateAccount(Account account) {
    // ...
}
```
`args(account,..)`这个pointcut表达式有两个目的  
1. 限制*目标方法*至少有一个参数，并且这个参数是`Account`类的实例
2. 通过advice参数传递参数的值  

传递参数的另外一个方法是在一个pointcut表达式里面申明好，advice直接引用：
```java
@Pointcut("com.xyz.myapp.CommonPointcuts.dataAccessOperation() && args(account,..)")
private void accountDataAccessOperation(Account account) {}

@Before("accountDataAccessOperation(account)")
public void validateAccount(Account account) {
    // ...
}
```

this、target、@within、@target、@annotation，和@args都可以用同样的方式绑定  
下面的两个例子展示了如何匹配有注解`@Auditable`的方法和如何提取注解的`AuditCode`参数  

第一个例子展示了`@Auditable`注解：
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Auditable {
    AuditCode value();
}
```
第二个例子是对应的advice：
```java
@Before("com.xyz.lib.Pointcuts.anyPublicMethod() && @annotation(auditable)")
public void audit(Auditable auditable) {
    AuditCode code = auditable.value();
    // ...
}
```

#### Advice参数和泛型
Spring AOP可以处理类泛型和方法泛型  
假如你有一个接口如下所示：
```java
public interface Sample<T> {
    void sampleGenericMethod(T param);
    void sampleGenericCollectionMethod(Collection<T> param);
}
```
你可以指定泛型为什么类型时才拦截方法：
```java
@Before("execution(* ..Sample+.sampleGenericMethod(*)) && args(param)")
public void beforeSampleMethod(MyType param) {
    // Advice implementation
}
```
这个方法在泛型指向集合的时候是不生效的。所以你不能像下边那样定义pointcut：
```java
@Before("execution(* ..Sample+.sampleGenericCollectionMethod(*)) && args(param)")
public void beforeSampleMethod(Collection<MyType> param) {
    // Advice implementation
}
```
要实现这种情况，你需要改变参数类型为`Collection<?>`，并且你需要手动校验集合中的每一个元素，这是不合理的，因为null值无法处理。

#### 确定参数名称
advice调用时的参数绑定是依赖于pointcut表达式里面的名称（用于申明advice参数名）和pointcut方法签名的名字相匹配，但是在java反射里边，参数名称是不可用的  
所以Spring AOP采用了以下策略却决定参数名称:
  
* 如果参数名已经被用户明确指定，那么指定的参数名会被使用。advice和pointcut注解都有一个可选属性`argNames`，你可以用它指定注解方法的参数名称    
这些参数名称在运行时也是可用的。下面这个例子展示了如何使用`argNames`属性：
```java
@Before(value="com.xyz.lib.Pointcuts.anyPublicMethod() && target(bean) && @annotation(auditable)",
        argNames="bean,auditable")
public void audit(Object bean, Auditable auditable){
    AuditCode code = auditable.value();
}
```
如果第一个参数是默认参数`JoinPoint`，`ProceedingJoinPoint`,或者`JoinPoint.StaticPart`，在配置`argNames`时你可以直接忽略这些默认参数  
举个例子，如果你修改上面的advice新增一个`JoinPoint`参数，`argNames`不需要涵盖它：
```java
@Before(value="com.xyz.lib.Pointcuts.anyPublicMethod() && target(bean) && @annotation(auditable)",
        argNames="bean,auditable")
public void audit(JoinPoint joinPoint, Object bean, Auditable auditable){
    AuditCode code = auditable.value();
}
```
当advice方法只有默认参数`JoinPoint`，`PorceedingJoinPoint`，和`Joint.StaticPart`时，可以不写`argNames`
```java
@Before("com.xyz.lib.Pointcuts.anyPublicMethod()")
public void audit(JoinPoint jp) {
    // ... use jp
}
```

* 使用`argNames`属性显得稍微有些笨拙，所以当`argNames`没有被指定时，Spring AOP将会在类的debug信息中查找，并从本地变量表中决定参数名称  
只要类编译时有debug信息(至少是`-g:vars`)就能得到这个信息。  
启用此标志进行编译的结果是：  
    1. 你的代码会更容易理解（反向工程）  
    2. class文件的大小会有轻微增大（一般可以忽略不计）
    3. 会移除编译器没有用到的本地变量  

    换句话说，使用这个标志你不会碰见任何困难  

* 如果代码被编译的时候没有必须的debug信息，Spring AOP会尝试推断参数的配对关系（举个例子，如果pointcut表达式里面只有一个参数绑定，而且advice也只有一个参数，那么这个配对关系就很明显）  
    如果在可用的信息里面绑定参数是不确定的，那么`AmbiguousBindingException`异常将会抛出
* 如果上面的所有策略都失败了，那么`IllegalArgumentException`异常将会抛出

#### proceed方法如果带参数
之前提过如何写一个带参数的`proceed`调用。这个解决方法需要确保advice的签名按顺序绑定了*目标方法*的每一个参数  
```java
@Around("execution(List<Account> find*(..)) && " +
        "com.xyz.myapp.CommonPointcuts.inDataAccessLayer() && " +
        "args(accountHolderNamePattern)")
public Object preProcessQueryPattern(ProceedingJoinPoint pjp,
        String accountHolderNamePattern) throws Throwable {
    String newPattern = preProcess(accountHolderNamePattern);
    return pjp.proceed(new Object[] {newPattern});
}
```
无论如何都要像上面的例子一样绑定  

### 2.4.7 advice顺序
当多个advice同时指向一个*目标方法*时，Spring AOP和AspectJ遵循同样的优先级规则：  
* 进入方法：优先级高的先执行（比如两个给定的`before`advice，优先级高的先执行）
* 离开方法：优先级高的后执行（比如两个给定的`after`advice，优先级高的后执行）  

当两个advice定义在不同的aspect类但指向同一个*目标方法*时，除非你在其他地方指定了，不然执行顺序是没有定义的。  
你可以直接控制执行的优先级顺序,有两个方式：  
1. aspect类实现`org.springframework.core.Ordered`接口  
2. aspect类加注解`@Order`  
两个切面`Ordered.getValue()`(或者注解的value)，谁的值更小，睡的优先级更高  
> 从Spring Framework 5.2.7开始，如果advice方法都定义在同一个aspect类中并且都指向同一个*目标方法*，那么他们的优先级是基于他们的advice类型的  
> 按照如下的顺序，从高到低：  
>   `@Around`,`@Before`,`@After`,`@AfterReturning`,`@AfterThrowing`  
> 但请注意因为Spring的`AspectJAfterAdvice`实现方式，任何在同一个切面类中的`@AfterReturning`或者`AfterThrowing`advice方法执行过后都会去执行`@After`advice方法  
> 当两个同样类型的advice(比如，两个`@After`advice方法)定义在同一个切面类中时，并且都指向同一个*目标方法*，这种情况下顺序是无法定义的  
> 因为没有办法从javac已经编译过的类反射中获取源码的申明顺序  
> 所以当遇到这种情况时，请考虑合并这两个advice方法，或者把重复advice方法提取到另外一个切面类中

## 2.5 Introductions  
Introductions(在AspectJ中叫做类型间声明) 让切面类可以申明*目标方法*所在对象实现指定接口，而且提供一个接口的实现类去代表那些对象  

你可以创建一个introduction通过使用`@DeclareParents`注解。这个注解被用来申明匹配的类型有一个新的父类  
举个例子，给定接口叫做`UsageTracked`然后这个接口的实现类叫做`DefaultUsageTracked`  
下面的切面申明了所有实现service的实现类也实现了`UsageTracked`接口（例如通过JMX公开统计信息）：
```java
@Aspect
public class UsageTracking {

    @DeclareParents(value="com.xzy.myapp.service.*+", defaultImpl=DefaultUsageTracked.class)
    public static UsageTracked mixin;

    @Before("com.xyz.myapp.CommonPointcuts.businessService() && this(usageTracked)")
    public void recordUsage(UsageTracked usageTracked) {
        usageTracked.incrementUseCount();
    }

}
```

## 2.6 切面类实例化模型

默认情况下，对application context来说每个切面类都是单例的。AspectJ将其称作单实例模型。可以使用备用的生命周期来定义Aspect  
Spring 支持AspectJ的`perthis`和`pertarget`实例化模型  
暂不支持`percflow`,`percflowbelow`，和`pertypewithin`  

你可以申明一个`perthis`切面通过制定`perthis`语句在注解`@Aspect`中：
```java
@Aspect("perthis(com.xyz.myapp.CommonPointcuts.businessService())")
public class MyAspect{
    private int someState;

    @Before("com.xyz.myapp.CommonPointcuts.businessService()")
    public void recordServiceUsage(){
        // ...
    }
}
```
在上面的例子中，`perthis`语句的作用就是每匹配一个service对象就创建一个切面实例。当一个service对象的方法被调用时，切面实例被第一次创建  
当service对象超出范围时，切面对象也会超出范围（暂不明白这里的超出范围指的是什么）  
在切面实例被创建之前，里面的advice方法不会被调用。只要切面实例被创建，并且service对象与一个切面关联的时候，advice才会在匹配的时候运行  

`pertarget`实例化模型的工作方式跟`perthis`完全相同

## 2.7 一个完整的AOP实例
当执行业务service的时候，有时候会因为并发原因失败（例如，一个因为获取悲观锁失败的操作）。如果重新尝试，很可能在下次尝试的时候成功  
当这种情况出现时，我们应该有一个明显的重试操作以避免向客户端发送`PessimisticLockingFailureException`。这个需求很明显跨越了多个service，很明显可以用切面来实现  

因为我们需要多次执行`proceed`方法，所以我们肯定需要around advice：

```java
@Aspect
public class ConcurrentOperationExecutor implements Ordered {

    private static final int DEFAULT_MAX_RETRIES = 2;

    private int maxRetries = DEFAULT_MAX_RETRIES;
    private int order = 1;

    public void setMaxRetries(int maxRetries) {
        this.maxRetries = maxRetries;
    }

    public int getOrder() {
        return this.order;
    }

    public void setOrder(int order) {
        this.order = order;
    }

    @Around("com.xyz.myapp.CommonPointcuts.businessService()")
    public Object doConcurrentOperation(ProceedingJoinPoint pjp) throws Throwable {
        int numAttempts = 0;
        PessimisticLockingFailureException lockFailureException;
        do {
            numAttempts++;
            try {
                return pjp.proceed();
            }
            catch(PessimisticLockingFailureException ex) {
                lockFailureException = ex;
            }
        } while(numAttempts <= this.maxRetries);
        throw lockFailureException;
    }

}
```
注意上面的切面类实现了`Ordered`接口，所以我们设置切面类的优先级是高于事务的（我们想每次尝试都是一个新事务）  
`maxRetries`和`order`属性都由Spring配置  
主要的操作都发生在`doConcurrentOperation`around advice。注意，在当前情况，我们应用了重试逻辑在每个`businessService()`。如果运行抛出`PessimisticLockingFailureException`异常，就会进行重试操作，除非重新操作次数已经耗尽。  

对应的Spring配置如下：
```xml
<aop:aspectj-autoproxy/>
<bean id="concurrentOperationExecutor" class="com.xyz.myapp.service.impl.ConcurrentOperationExecutor">
    <property name="maxRetries" value="3"/>
    <property name="order" value="100"/>
</bean>
```
提炼aspect让他只有在幂等操作的时候才重试（幂等：函数多次运行结果与一次运行结果相同），我们可以定义`Idempotent`注解：
```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Idempotent{}
```
现在可以使用`Idempotent`注解去标注需要重试的service 方法，同时我们的pointcut表达式也需要修改：
```java
@Around("com.xyz.myapp.CommonPointcuts.businessService() && " +
        "@annotation(com.xyz.myapp.service.Idempotent)")
public Object doConcurrentOperation(ProceedingJoinPoint pjp) throws Throwable {
    // ...
}
```
# 3.  基于架构的AOP支持（xml配置形式的）
xml配置形式的AOP跟基于AspectJ的形，只是方式不一样，用的pointcut表达式都是一样的，这里不细讲，详细参考文末的官方文档



> 详情参考 [Spring官方文档](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/core.html#aop)





