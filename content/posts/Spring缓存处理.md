---
    title: "Spring缓存集成"
    date: 2018-09-05
    tags: ["spring"]
    
---

# 1.了解缓存概念
```
                                                        缓存和缓冲(Cache vs Buffer)
缓存和缓冲一般来说都是交替使用的，需要知道的是他们是两个完全不同的东西。

buffer(缓冲)是用在快慢介质中间作临时数据存储用，介质一方将会等待另一方的操作，这会造成性能损耗，为了缓解，buffer用整块数据的移动代替小块数据多次移动。
这样buffer数据读写只有一次，并且buffer对介质双方来说至少有一方是可见的。

cache(缓存)根据定义他是隐藏的，双方都不知道缓存发生了。他提高性能体现在一个数据被多次读取的情况
```
Spring缓存针对是java的方法，根据缓存里的信息减少执行的次数。每一次目标方法执行前都会判断该方法是否已经被调用过，并且参数一致。如果已经被调用，那么目标方法不会被执行，直接从缓存中获取结果。  
> 这种方式对方法有要求，需要确保方法一组参数只返回唯一个结果，不论调用多少次该方法

Spring只提供了缓存的逻辑，意味着你需要提供一个缓存的实现，来完成实际的数据储存。对应的实现接口是`org.springframework.cache.Cache`和`org.springframework.cache.CacheManager`
  
当然Spring提供了现成的缓存实现：
1. JDK`java.util.concurrent.ConcurrentMap`为基础的缓存
2. [Ehcache 2.x](https://www.ehcache.org/)
3. Gemfire cache
4. [Caffeine](https://github.com/ben-manes/caffeine/wiki)
5. 符合JSR-107的缓存(Ehcache 3.x)

> 缓存的抽象并没有特别的处理多线程和多进程的环境，是由缓存的实现去处理

如果你处在多进程环境，你需要正确的配置你的缓存实现。多个节点相同数据的备份应该是足够的，但还是要依赖于你的具体情况。  
但是，如果你在应用的处理过程中改变了数据，那你另外需要一个的传播机制。  
缓存的过程就是一个查找是否存在，然后执行目标方法，最后保存结果的过程。这个过程是没有锁的，如果多线程的情况下并发保存或者删除数据，数据可能会被污染。  
某些缓存提供者对这种情况有专门处理，详细参考缓存提供者的文档  

要使用Spring的缓存集成，你需要注意这两个方面：
* 缓存声明：确定需要缓存的方法和其策略
* 缓存配置：后台缓存数据是怎么存储和怎么读取的

# 2.声明式的基于注解的缓存
Spring对于缓存声明提供了一系列的java注解：
* `@Cacheable`:触发缓存填充
* `@CacheEvict`:触发缓存释放
* `@CachePut`:在不干扰方法执行的前提下更新缓存
* `@Caching`:重新分组多个缓存操作并应用到一个方法上
* `@CacheConfig`:在类上配置一些公用的缓存配置
## 2.1 `@Cacheable`注解
这个注解的是用来指定方法是可以缓存的  
默认参数name是缓存的名称用来和注解的方法关联：
```java
@Cacheable("books")
public Book findBook(ISBN isbn) {...}
```
在上面的例子中，`findBook`方法是与缓存名称`books`相关联的。每次方法调用都会检测这个方法是否已经运行过并且不需要重复调用。  
虽然大多数情况下缓存只声明一个，但是注解是允许多个名称的，意味着对应的缓存也有多个。这种情况下，在方法调用前检查每个缓存，如果至少有一个缓存命中，那他关联的缓存都会被返回。  
```java
@Cacheable({"books", "isbns"})
public Book findBook(ISBN isbn) {...}
```
### 2.1.1 默认主键生成
因为缓存本质上是一个key-value结果的储存，因此每次调用一个缓存方法，都需要将它转为一个合适的key用于缓存访问。  
Spring用的`KeyGenerator`基于一下算法：
* 如果没有给定参数，返回`SimpleKey.EMPTY`
* 如果只有一个参数，那么直接返回那个实例
* 如果超过一个参数，那么返回`SimpleKey`，它包含了所有的参数  

这种方法在大多数使用场景都能胜任，只要参数有`natural key`并且实现了`hashCode()`和`equals()`方法。如果没有，那么你需要改变策略。  

提供不同的默认主键生成器，你需要实现`org.springframework.cache.interceptor.KeyGenerator`接口  

> Spring 4.0.Earlier版本改变了默认的主键生成策略，如果有多个参数，只考虑了`hashCode()`没有考虑`equals()`。这可能造成主键冲突(参考[SPR-10237](https://github.com/spring-projects/spring-framework/issues/14870))  
> 新的`SimpleKeyGenerator`使用了复合的主键来应对这种场景  
> 如果你仍然想使用之前的主键策略，你可以配置`org.springframework.cache.interceptor.DefaultKeyGenerator`类，或者创建一个自定义基于hash的`KeyGenerator`实现

### 2.1.2 自定义主键生成策略
实际情况中，方法的多个参数并不是每一个都需要用于主键生成，像下面的例子:
```java
@Cacheable("books")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
isbn明显是生成主键的关键属性，而另外两个boolean值应该是可有可无  
在这种情况下可以使用`@Cacheable`的属性`key`值来指定哪些用来生成主键。你可以使用[SpEL](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/core.html#expressions)来选择参数（或者是他们的嵌套属性），运行操作，或者是调用任意的方法不用写任何的代码或者实现任何的接口。  
随着代码量的增多，之前的默认主键生成方法可能适合一部分方法，但是很难适应所有方法  

下面的例子使用不同的SpEL表达式声明：
```java
@Cacheable(cacheNames="books", key="#isbn")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)

@Cacheable(cacheNames="books", key="#isbn.rawNumber")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)

@Cacheable(cacheNames="books", key="T(someType).hash(#isbn)")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
上面的例子展示了选择某个参数，或者某个参数的属性，以及任意一个随机的静态方法  

如果负责生成主键的方法十分特殊或者他需要共享，你可以定义一个自定义的`keyGenerator`。需要`@Cacheable`的属性`keyGenerator`，他需要一个bean name作为参数：
```java
@Cacheable(cacheNames="books", keyGenerator="myKeyGenerator")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
> `key`和`keyGenerator`只能声明一个，同时声明会跑错

### 2.1.3 默认缓存解析
缓存抽象类使用了一个简单的`CacheResolver`，它使用`CacheManager`检索操作层面的缓存定义  
如果要提供其他的缓存解析器，你需要实现`org.springframework.cache.interceptor.CacheResolver`接口
### 2.1.4 自定义缓存解析
默认的缓存解析适用于应用只有单个`CacheManager`并且没有复杂的缓存解析需求  
如果应用有多个缓存manager，你可以在每个操作上设置`cacheManager`：
```java
@Cacheable(cacheNames="books", cacheManager="anotherCacheManager") 
public Book findBook(ISBN isbn) {...}
```
你也可以类似的替换`CacheResolver`：
```java
@Cacheable(cacheResolver="runtimeCacheResolver") 
public Book findBook(ISBN isbn) {...}
```

> 从Spring 4.1开始，不再维护`value`属性，因为这个信息可以由`CacheResolver`来提供，注释的内容如何不再生效
> 
> 跟`key`和`keyGenerator`类似，`cacheManager`和`cacheResolver`也是相互排斥的。  
> 原因是自定义的`CacheManager`是被`CacheResolver`的实现所忽略的

### 2.1.5 同步的缓存
在多线程的环境，某一个操作可能被同样的参数并发调用。默认情况，缓存抽象类没有任何锁，可能造成同样的值被计算很多次，这违背了缓存的初衷  

在这种场景下，你可以使用`sync`属性去命令缓存提供者在值计算完毕后对缓存键值上锁。目的是只有一个线程在计算结果，其他的需要阻塞直到键值已经更新完毕
```java
@Cacheable(cacheNames="foos", sync=true) 
public Foo executeExpensiveOperation(String id) {...}
```
> 这是一个可选的特性，有可能你使用的缓存提供方不支持它。目前核心框架实现的所有`CacheManager`都支持他。更多信息需要参考提供方的文档。  

### 2.1.6 有条件的缓存
有时候，方法并不是任何时候都需要缓存(比如在某个特定的参数值才缓存)。`condition`参数可以解决这个问题，他需要一个SpEL表达式，这个表达式的结果是true或者false，代表开启缓存  
下面这个例子代表只有方法参数`name`长度小于32时才启用缓存
```java
@Cacheable(cacheNames="book", condition="#name.length() < 32") 
public Book findBook(String name)
```
除了`condition`，你还可以指定`unless`参数去阻止缓存。不像`condition`，`unless`表达式是在方法被调用后才计算。  
现在扩展之前的例子，也许我们想缓存简装版的书籍，而不是精装版：
```java
@Cacheable(cacheNames="book", condition="#name.length() < 32", unless="#result.hardback")
public Book findBook(String name)
```
缓存抽象类是支持`java.util.Optional`的，仅当其值存在时才将他的内容作为缓存。`#result`始终是指业务实体，不会是他的封装。所以之前的例子还可以进一步重写：
```java
@Cacheable(cacheNames="book", condition="#name.length() < 32", unless="#result?.hardback")
public Optional<Book> findBook(String name)
```
注意`result`仍然指`Book`而不是`Optional`。因为他可能为null，应该使用`safe navigation`操作符

### 2.1.7 缓存SpEL中可用的上下文参数
每个`SpEL`表达式都根据一个专门的`context`对象来计算。这个`context`包含一些默认的参数，可以用来计算主键或者运行条件，参照下表：

|名称|位置|描述|例子|
|---|---|---|---|
|`methodName`|Root object|被调用的方法名称|`#root.methodName`|
|`method`|Root object|被调用的方法|`#root.method.name`|
|`target`|Root obejct|被调用的目标对象|`#root.target`|
|`targetClass`|Root object|被调用的目标类|`#root.targetClass`|
|`args`|Root object|被调用方法的参数（数组）|`#root.args[0]`|
|`caches`|Root object|当前运行方法的缓存集合|`#root.cache[0].name`|
|参数名|Evaluation context|任何方法的参数名称。如果名称不可用(也许是因为没有debug信息)，可以使用`#a<#arg>`，其中`#arg`代表参数的下标(从0开始)|`#iban`或者`#a0`（你也可以用`#p0`或者`#p<#arg>`作为别名）|
|`result`|Evaluation context|方法调用的结果（拿来缓存的值）。只在`unless`表达式，`cache put`表达式（用于计算主键的），或者`cache evict`表达式（`beforeInvacation`的值是`false`）时可用。为了支持包装类（比如`Optional`)，`#result`指代的实体对象，不是包装对象|`#result`|


## 2.2 `CachePut`注解
当缓存需要更新并且不希望干扰方法的执行时，你可以使用`CachePut`注解。也就是该方法任何时候都会被调用，并且它的结果将会放到缓存中（具体参照注解参数配置）。它也支持`@Cacheable`注解支持的参数，它应该应用于缓存填充而不是方法流优化。下面是一个使用例子：
```java
@CachePut(cacheNames="book", key="#isbn")
public Book updateBook(ISBN isbn, BookDescriptor descriptor)
```

> 强烈不推荐在同一个方法上使用`CachePut`和`Cacheable`。`Cacheable`会在检查到方法有缓存的时候跳过执行，`CachePut`为了更新缓存强制执行调用。同时声明会导致意想不到的操作（除非极端情况，比如两个注解的参数互相排除了对方），所以尽量避免这么声明

## 2.3 `CacheEvict`注解
除了缓存填充，Spring也提供了缓存释放注解`@CacheEvict`。跟`@Cacheable`注解类似，`@CacheEvict`也需要指定影响的缓存（一个或者多个），允许自定义缓存和主键的解决方案，同样也可以指定生效条件。除了这些跟`Cacheable`一样的特性，`CacheEvict`还有一个额外的参数`allEntries`，它代表是否执行整个缓存范围的释放，而不是仅仅一个键值对（基于主键）
```java
@CacheEvict(cacheNames="books", allEntries=true) 
public void loadBooks(InputStream batch)
```
这个选项在需要清空整个缓存区域时非常有用，如果单独的清除每个键值对，那将耗费大量时间。在上面的例子中，一个操作就可以清空所有的键值对。注意在这个场景你指定的主键没有任何作用。  

你也可以指定释放操作在方法调用后（默认）或者调用前执行。默认情况下都是调用后执行，可以通过属性`beforeInvcation`来指定调用前执行，这样方法是否运行完都不会影响到释放操作  

注意`@CacheEvict`可以在void方法上使用，方法相当于一个触发器，返回结果将会被忽略。

## 2.4 `@Caching`注解
有些时候，相同类型的多个注解（比如`@CacheEvict`或者`@CachePut`）需要指定在一个方法上——例如，因为条件不同或者主键表达式不同的两个不同的缓存。`@Caching`注解可以让多个`@Cacheable`,`@CachePut`,和`@CacheEvict`注解集成用在同一个方法上。下面这个例子用了两个`@CacheEvict`注解：
```java
@Caching(evict = {@CacheEvict("primary"),@CacheEvict(cacheNames="secondary",key="#p0")})
public Book importBooks(String deposit, Date date)
```

## 2.5 `@CacheConfig`注解
当目前为止，我们讨论的缓存操作提供了很多的自定义选项。但是有些选项是通用的，如果方法里的所有操作都需要配置这个选项，并且还是相同的值，那么就太麻烦了。所以Spring提供了`@CacheConfig`注解，这是一个类级别的注解，可以用它来指定一些共用的选项信息。
下面的例子用`@CacheConfig`指定了该类所有缓存操作的缓存名称
```java
@CacheConfig("books") 
public class BookRepositoryImpl implements BookRepository {

    @Cacheable
    public Book findBook(ISBN isbn) {...}
}
```
`@CacheConfig`是一个类级别的注解可以分享的选项有：缓存名称、自定义`KeyGenerator`、自定义`CacheManager`、以及自定义`CacheResolver`。把这个注解放在类上只是共享配置，并不会打开任何缓存操作。  

一个操作级别的自定义参数始终可以覆盖在`@CacheConfig`上的配置。缓存自定义选项有三个级别：
* 全局配置，对`CacheManager`,`KeyGenerator`生效。
* 类级别，用`CacheConfig`。
* 操作级别配置  

## 2.6 让缓存注解生效
想许多Spring特性一样，缓存注解不是自动触发的，他们需要一个有效声明（当你发觉问题有可能是缓存带来的，你可以只移除一行配置行，而不是你代码里面的所有注解）  

让缓存注解生效很简单，只需要在任意一个`@Configuration`类上加注解`@EnableCaching`
```java
@Configuration
@EnableCaching
public class AppConfig {
}
```
或者，通过xml配置，你可以使用`cache:annotation-driven`
```xml
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:cache="http://www.springframework.org/schema/cache"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/cache https://www.springframework.org/schema/cache/spring-cache.xsd">

        <cache:annotation-driven/>
</beans>
```
上面两种方式都有大量配置项可以调整，他们通过aop实际的影响缓存行为。这些配置项跟[@Transactional](https://docs.spring.io/spring-framework/docs/current/spring-framework-reference/data-access.html#tx-annotation-driven-settings) 相似    
> 默认处理缓存注解的方式是通过代理实现的，他只会拦截通过代理的调用。因此在同一个类的本地调用，是无法被拦截到的（具体参照Spring AOP).如果需要其他的拦截模式，考虑切换到aspectj模式结合编译时或者加载时的weaving。  

> 更多自定义配置可以实现`CachingConfigurer`，参考[javadoc](https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/javadoc-api/org/springframework/cache/annotation/CachingConfigurer.html)  

自定义缓存配置项：

|xml属性|注解属性|默认值|描述|
|---|---|---|---|
|`cache-manager`|参照[CachingConfigurer](https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/javadoc-api/org/springframework/cache/annotation/CachingConfigurer.html) 文档|`cacheManager`|指代缓存管理器使用的名称。默认的缓存管理器或者没有设置`cahcheMnager`，在他的后台会初始化一个默认的`CacheResolver`。如果你需要对缓存解析更细粒度的管理，考虑设置`cache-resolver`属性|
|`cache-resolver`|参照[CachingConfigurer](https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/javadoc-api/org/springframework/cache/annotation/CachingConfigurer.html) 文档|`SimpleCacheResolver`，缓存管理使用的默认`cacheManger`|缓存解析器的bean name，缓存解析器是缓存的底层实现。这个属性不是必须的，仅当需要替代`cache-manager`属性时才指定|
|`key-generator`|参照[CachingConfigurer](https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/javadoc-api/org/springframework/cache/annotation/CachingConfigurer.html) 文档|`SimpleKeyGenerator`|自定义主键生成器的名称|
|`error-handler`|参照[CachingConfigurer](https://docs.spring.io/spring-framework/docs/5.2.9.RELEASE/javadoc-api/org/springframework/cache/annotation/CachingConfigurer.html) 文档|`SimpleCacheErrorHandler`|自定义缓存错误处理器的名称。默认情况下，缓存相关操作抛出的异常会直接抛给调用方|
|`mode`|`mode`|`proxy`|默认`proxy`模式代表注解会通过Spring AOP框架处理，生成原类的代理类。可选择的替代参数是`aspectj`|
|`proxy-target-class`|`proxyTargetClass`|`false`|只在mode值是`proxy`时生效。控制为缓存类生成什么类型的缓存代理。如果属性是`true`，以类为基础的代理将会被创建。如果属性是`false`或者属性没有手动配置，标准的JDK接口代理会被创建（两者的具体差距可以参考[代理机制](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#aop-proxying) )
|`order`|`order`|Ordered.LOWEST_PRECEDENCE|当前类里的缓存切面逻辑的执行优先权，具体参考AOP执行顺序|

> **缓存注解的方法可见性**
> 当你使用proxy mode，你应该将你的缓存注解放到public方法上。如果放到诸如protected,private,或者 package可见的方法上，虽然没有异常提示，但是你的注解将不会有任何效果。如果有这样的需求，可以考虑使用AspectJ

> Spring推荐将缓存注解放到实现类上，而不是接口上。你当然可以吧缓存注解放到接口上或者接口的方法上，但是前提是`proxy-target-class`的值必须是false。如果`proxy-target-class`值是true或者`mode="aspectj`，缓存配置将没有任何效果

> 在proxy mode(默认情况)，只有外部的方法调用会被拦截并处理。内部的调用，指类内部的方法掉了同类下的另一个方法，这样的调用就算方法有缓存注解也不会有任何效果。这样的情况请考虑使用`aspectj`mode。另外，必须完全初始化代理才能提供预期的支持，所以不应该在初始化代码中（`@PostConstruct`）使用缓存注解


## 2.7 使用自定义注解
> **自定义注解和AspectJ**  
> 这个特性只能在基于代理的方法上使用，非代理方法需要使用AspectJ  
>
> `spring-aspects`项目模块只定义了标准注解的切面。如果你定义了你自己的注解，你需要为它定义对应的切面类。`AnnotationCacheAspect`类就是一个例子

Spring可以让你用自定义注解去申明什么方法触发缓存填充和释放。这是一个简单的模板机制，因为他可以避免缓存注解的重复声明，特别是指定了主键和条件，或者代码库不允许外部导入(org.springframework)时特别有用。跟其余的模板注解相同，你可以使用`@Cacheable`，`@CachePut`，`@CacheEvict`，和`@CacheConfig`作为元注解（意思就是，能够在其他注解上声明注解）  
下面的例子，我们替换一个公用得问`@Cacheable`注解为我们的自定义注解:
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Cacheable(cacheNames="books",key="#isbn")
public @interface SlowService{
}
```
上面的例子我们定义了自己的`SlowService`注解，他被`@Cacheable`注解修饰，现在我们可以替换掉下面的代码
```java
@Cacheable(cacheNames="books", key="#isbn")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
那如果用我们申明的自定义注解，可以很方便的写为：
```java
@SlowService
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
即使`@SlowService`不是Spring注解，在运行时容器也能自动获取他的声明。注意，如前所述，需要启用注解驱动。

# 3.JCache(JSR-107)注解
从4.1版本开始，Spring缓存全面支持JCache标准注解：`@CacheResult`,`@CachePut`,`@CacheRemove`,和`@CacheRemoveAll`以及`@CacheDefaults`,`@CacheKey`,和`@CacheValue`配合。你可以使用这些注解即使没有把缓存存储到JSR-107上。内部实现使用了Spring的缓存抽象类，并提供了默认的符合规范的`CacheResolver`和`KeyGenerator`实现。换句话说，如果你已经使用了Spring的缓存抽象，你可以切换到这些标准注解并且不需要改变你的缓存存储（或者配置）。  

## 3.1 特征总结
下面是Spring缓存注解和对应的JSR-107注解的区别：

|Spring|JSR-107|备注|
|---|---|---|
|`@Cacheable`|`@CacheResult`|基本相同，`@CacheResult`可以缓存指定的异常还能强制执行方法不管缓存的内容|
|`@CachePut`|`@CachePut`|当Spring用方法调用的结果更新缓存时，JCache需要将它当做一个参数(`@CacheValue`注解修饰)传递。因为这个不同，JCache是允许在实际方法执行前或者执行后更新缓存的|
|`@CacheEvict`|`@CacheRemove`|基本相同。`@CacheRemove`支持方法调用异常时条件释放|
|`@CacheEvict(allEntries=true)`|`@CacheRemoveAll`|参照`@CacheRemove`|
|`@CacheConfig`|`@CacheDefaults`|提取相同的配置，相似的风格|

JCache也有CacheResolver概念：`javax.cache.annotation.CacheResolver`，跟Spring的`CacheResolver`接口是完全一样的，除了JCache只支持一种缓存外。默认情况下，一个简单的实现根据注解中声明的名称去检索要使用的缓存。需要注意的是，如果没有缓存名称指定，会自动生成一个默认的。`@CacheResult#cacheName()`api文档有更详细的信息。  

`CacheResolver`实例是通过`CacheResolverFactory`来检索的。可以为每个缓存操作自定义factory：
```java
@CacheResult(cacheNames="books", cacheResolverFactory=MyCacheResolverFactory.class) 
public Book findBook(ISBN isbn)
```
> 对于所有引用的类，Spring会根据指定类型尝试去定位一个bean。如果多个匹配项存在，一个新的实例会被创建，并且使用常规bean生命周期回调，就像依赖注入一样。

跟Spring的`KeyGenerator`目的一样，`javax.cache.annotation.CacheKeyGenerator`被用来生成主键。默认情况，方法的所有参数都被考虑在内，除非至少一个参数被`@CacheKey`注解修饰。这个Spring的自定义主键生成非常相似。下面的例子就是跟Spring的一个对比：
```java
@Cacheable(cacheNames="books", key="#isbn")
public Book findBook(ISBN isbn, boolean checkWarehouse, boolean includeUsed)

@CacheResult(cacheName="books")
public Book findBook(@CacheKey ISBN isbn, boolean checkWarehouse, boolean includeUsed)
```
你也可以在这个操作上指定`CacheKeyResolver`，方法跟指定`CacheResolverFactory`相同。  

JCache可以管理被注解方法抛出的异常。他可以阻止缓存的更新，也可以缓存异常而不是再去调用一次方法。假定ISBN无效时会抛出`InvalidIsbnNotFoundException`。下面的例子，每次调用都用一个无效的，并且相同的ISBN，多次调用的情况下会直接抛出异常，而不是再次执行方法：
```java
@CacheResult(cacheName="books", exceptionCacheName="failures"
            cachedExceptions = InvalidIsbnNotFoundException.class)
public Book findBook(ISBN isbn)
```
## 3.2 开启JSR-107支持
除了Spring的申明注解支持外，不需要其他的操作来启用JSR-107。如果classpath内部有JSR-107API和`spring-context-support`模块，那么`@EnableCaching`和`cache:annotation-driven`元素会自动启用JCache支持

> 两种注解形式可以随意使用，唯一需要注意的是，如果Spring和JSR-107都影响了相同的缓存，你应该保证主键生成器一致

