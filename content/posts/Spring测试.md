---
    title: "Spring集成测试"
    date: 2017-09-15
    tags: ["spring","unit-test"]
    
---

# 1. 概览
一般情况下我们要测试项目或者平台的某个功能，先要部署启动应用才能进行，如果在不启动应用或者连接其他企业级平台的情况下，就能做相应的集成测试，那么将会极大的缩短测试时间。比如通过ORM框架访问数据库的时候，想确定sql的正确性，或者对象实例映射的正确性  

介绍Spring的测试框架，第一个就离不开`org.springframework.test`包，他对Spring容器集成测试有很大的价值，并且它不依赖于任何其他的部署环境或者应用服务。虽然他比纯粹的单元测试慢，但是比任何等同于`Selenium`的测试，或者需要依赖于部署应用服务的测试都快  

Spring TestContext框架是以注解为驱动支持单元和集成测试的。这个`TestContext`不管实际使用的是什么测试框架，在Junit，TestNG，以及其他测试框架环境中都能进行测试  

# 2. 集成测试的目标
Spring集成测试主要有下面几个主要目标：
* 在测试之间管理Spring IoC容器的缓存
* 为测试的资源实例提供依赖注入
* 提供适合集成测试的事务管理
* 提供Spring指定的基础类以帮助开发者写集成测试  

接下来的子章节是对上面几个目标的详细描述

## 2.1. 上下文管理和缓存
Spring TestContext框架提供了`ApplicationContext`实例和`WebApplicationContext`实例的一致性加载，以及这些上下文对象的缓存。支持缓存和加载这些上下文对象是非常重要的，因为启动时间是个很严重的问题，这个时间的消费并不是Spring容器自身消耗的，而是对象实例化需要时间。举个例子，一个项目有50到100个Hibernate的映射文件，那么将要花费10到20秒的时间去加载这些映射文件,如果每次测试都有这个花费，那么会拖慢整个测试进度，减少开发者的产出。    

典型的测试类申明要么是xml的资源位置数组或者Groovy的配置源数据（一般在classpath目录下），又或者是配置应用的成员类数组。这些位置或者类跟`web.xml`中的申明基本类似  

默认情况下，一旦加载，每次测试都复用的一个`ApplicationContext`。  因此，一个测试套件（test suite)只会有一次初始化应用的过程，每次子测试可以节省大量时间。这里说的测试套件(test suite)术语代表在一个JVM里面运行的所有测试-比如说，一个由Ant，Maven，或者Gradle构建的项目中运行的所有测试。在极少情况下，`ApplicationContext`会被污染需要重新加载（举个例子，通过修改bean的定义或者应用对象的状态）TestContext框架可以通过配置重载配置信息，并在执行下次测试之前重新构建`ApplicationContext`。下文中有详细操作。  

## 2.2. 测试资源的依赖注入
当`TestContext`框架加载你的`ApplicationContext`时，他可以通过依赖注入添加任意的配置到你的测试实例。他提供了一个简明的机制，通过`ApplicationContext`中的预配置bean来构建你测试所需要的资源环境。他的最大好处是每个测试场景都可以共用一个`ApplicationContext`，避免一次测试起一次环境  

现在假如我们有一个类`HibernateTitleRepository`，他实现了`Title`领域实体（domain entity)的数据访问逻辑。我们想写一个集成测试以测试下面几个方面：  
* Spring的配置：所有`HibernateTitleRepository`相关的配置是否正确关联和展示？
* Hibernate的映射文件配置：映射是否正确并且延迟加载的配置是否到位？
* `HibernateTitleRepository`的逻辑：该类配置实例的运行是否符合预期？  

依赖注入的详细内容后面会讲到  

## 2.3. 事务管理
在测试中访问真实数据库的一个常见问题是测试对持久性存储状态的影响。即使你使用的是开发数据库，更改状态也可能会影响到进一步的测试。还有许多操作例如插入或者修改持久数据，没有事务都是不能运行的  

`TestContext`框架解决了这个问题。默认情况下，框架会为每次测试创建和回滚事务。你可以在假定有事务的前提下写测试代码。如果你在测试中调用事务的代理对象，根据他们配置的事务语句，决定他们是否能正常运转。另外，如果一个测试方法在事务管理的范围内删除了选中表的内容，默认情况下事务会回滚，数据库会返回到执行测试之前的状态。为测试提供的事务支持是由`PlatformTransactionManager`bean来提供的  

如果你想提交一个事务（一般来说不会，在你想填充或者修改数据库的时候有用），你可以通过TestContext框架来提交事务以代替使用`@Commit`注解的回滚  

详细内容后面会讲到  

## 2.4. 集成测试的支持类
`TestContext`框架提供了多个抽象支持类，他们简化了集成测试的编写。这些基础测试类为测试框架提供了定义明确的钩子和方便的实例参数和方法，他们能让你访问：
* `ApplicationContext`，用于执行显式的bean查找或者测试整个上下文的状态。
* `JdbcTemplate`，用于执行sql表达式。你可以查询数据库相关应用代码执行前后的数据库状态，并且Spring确保这些查询都在同一个事务中。党和ORM框架配合使用时，需要确保避免[false positives](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-tx-false-positives)  

另外你可能想创建你自定义的支持类，更多信息可以参考[TestContext framework](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-framework)  

# 3. JDBC测试的支持
JDBC相关的工具方法在类`JdbcTestUtils`类中，他在`org.springframework.test.jdbc`包下。它简化了标准的数据库测试场景。`JdbcTestUtils`提供了以下静态的工具方法：  
* `countRowsInTable(..)`:计算指定表有多少行数据
* `countRowsInTableWhere(..)`:计算指定表有多少行数据通过提供的where条件进行限制
* `deleteFromTables(..)`:删除指定表的所有行
* `deleteFromTableWhere(..)`:删除指定表的数据行通过提供的where条件进行限制
* `dropTables(..)`:Drop指定表  

> `AbstractTransactionalJUnit4SpringContextTests`和`AbstractTransactionalTestNGSpringContextTests`代理了前面提及的`JdbcTestUtils`类的方法。  
> `spring-jdbc`模块支持配置和启动一个集成的数据库，你可以用它进行集成测试。更多细节，参考[Embedded Database Support](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc-embedded-database-support) 和 [ Testing Data Access Logic with an Embedded Database](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc-embedded-database-dao-testing)  

# 4. 注解
这个章节介绍你在测试Spring应用时可以用的注解。它包含如下几个主题：  
* Spring 测试注解
* 标准注解支持
* Spring JUnit 4 测试注解
* Spring JUnit Jupiter 测试注解
* 测试元注解

## 4.1. Spring 测试注解
Spring框架提供了如下Spring特有的注解，你可以使用他们在你的单元和集成测试中。查看他们对应的javadoc以查找更多信息，包括默认的属性值，属性别名，和其他细节。  

Spring测试注解包括：
* `@BootstrapWith`
* `@ContextConfiguration`
* `@WebAppConfiguration`
* `@ContextHierarchy`
* `@ActiveProfiles`
* `@TestPropertySource`
* `@DynamicPropertySource`
* `@DirtiesContext`
* `@TestExecutionListeners`
* `@Commit`
* `@Rollback`
* `@BeforeTransaction`
* `@AfterTransaction`
* `@Sql`
* `@SqlConfig`
* `@SqlMergeMode`
* `@SqlGroup`  

### `@BoostrapWith`
`@BootstrapWith`是一个类级别的注解，你可以使用它配置Spring TestContext框架是怎样引导启动的。具体可以使用`@BootstrapWith`去指定一个自定的`TestContextBootstrapper`。查看[bootstrapping the TestContext framework](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-bootstrapping) 以获取详细信息  

### `@ContextConfiguration`
`@ContextConfiguration` 定义类级别的源数据，常用来决定集成测试如何加载和配置一个`ApplicationContext`。具体的，可以使用`@ContextConfiguration`声明应用上下文的资源位置，或者用于加载上下文的组件类    

资源位置，一般来说就是在classpath路径下的XML的配置文件或者Groovy的脚本，而组件类一般来说是`@Configuration`注解的类。但是，资源位置可以引用文件系统中的文件和脚本，并且组件类可以是`@Component`类，`@Service`类，其他等等。更多参照[Component Classes](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management-javaconfig-component-classes)  

下面的例子`@ContextConfiguration`注解指向了一个XML文件：
```java
@ContextConfiguration("/test-config.xml")
class XmlApplicationContextTests{}
```

下面的例子`@ContextConfiguration`指向一个类：
```java
@ContextConfiguration(classes = TestConfig.class)
class ConfigClassApplicationContextTests{}
```

另外还可以使用`@ContextConfiguration`声明`ApplicationContextInitializer`类，这种方法也可以声明资源位置和组件类：
```java
@ContextConfiguration(initializers = CustomContextIntializer.class)
class ContextInitializerTests{}
```

你也可以选择`ContextConfiguration`申明`ContextLoader`的方式也行。注意，你通常不需要显式的配置loader，因为默认的loader支持`initializers`和资源位置或组件类。  
下面的例子同时声明了一个资源位置和一个loader:
```java
@ContextConfiguration(locations="/test-context.xml",loader=CustomContextLoader.class)
class CustomLoaderXmlApplicationContextTests{}
```

> `@ContextConfigurtion`对继承资源位置或者配置类提供了支持，还有由父类或者封闭类声明的context initializers  

详情参考 [Context Management](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management) ,[@Nested test class configuration](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-nested-test-configuration) 以及`@ContextConfiguration`的API文档  

### `@WebAppConfiguration`
`@WebAppConfiguration`是一个类级别的注解，它能将为集成测试声明的`ApplicationContext`指定为`WebApplicationContext`。`WebAppConfiguration`注解仅仅在测试类上存在，为确保`WebApplicationContext`是为测试加载，使用默认值`file:src/main/webapp`作为web应用的根路径（资源仓库路径）。资源仓库路径用于在后台创建`MockServletContext`，它被用作`WebApplicationContext`的`ServletContext`  

下面是如何使用`@WebAppConfiguration`注解：
```java
@ContextConfiguration
@WebAppConfiguration
class WebAppTests{}
```
如果你的资源仓库路径不是默认的`file:src/main/webapp`，你可以指定你自己的资源仓库路径，使用默认的`value`属性。可以支持`classpath:`和`file:`资源前缀。如果没有提供资源前缀，这个路径会被假定位文件系统资源。下面的例子展示了怎样指定一个classpath资源：
```java
@ContextConfiguration
@WebAppConfiguration("classpath:test-web-resources")
class WebAppTests{}
```

注意`WebAppConfiguration`必须与`ContextConfiguration`配合使用，不管在单个测试类还是一个测试类的层次结构中。详情参考[@WebAppConfiguration](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/web/WebAppConfiguration.html) API文档

### `@ContextHierarchy`
它是一个类级别的注解，为集成测试定义`ApplicationContext`实例的层次结构。`@ContextHierarchy`应该由一个`@ContextConfiguration`的实例集合来申明，其中每一个都定义context层级关系中的一级。下面的例子展示了`@ContextHierarchy`在单个测试类中的的使用（它也可以用在一个测试类的层次结构中）
```java
@ContextHierarchy({
    @ContextConfiguration("/parent-config.xml"),
    @ContextConfiguration("/child-config.xml")
})
class ContextHierarchyTests{}
```
```java
@WebAppConfiguration
@ContextHierarchy({
    @ContextConfiguration(classes = AppConfig.class),
    @ContextConfiguration(classes = WebConfig.class)
})
class WebIntegrationTests{}
```

如果你需要在测试类的层次结构中对指定层级的配置进行合并或者重写，那么需要一个别名值来对应层级，在设置`@ContextHierarchy`的每个`@ContextConfiguration`层级时，需要给他们指明参数`name`的值。详情参考[Context Hierarchies](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management-ctx-hierarchies) 和[ @ContextHierarchy](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/ContextHierarchy.html) api文档  

### `@ActiveProfiles`
它是类级别的注解，当为继承测试加载`ApplicationContext`时用来声明启用哪些bean定义配置文件  

下面的例子表示启用了`dev`配置文件：
```java
@ContextConfiguration
@ActiveProfiles("dev")
class DeveloperTests{}
```

下面的例子表示`dev`和`integration`配置文件都应该启用：
```java
@ContextConfiguration
@ActiveProfiles({"dev","integration"})
class DeveloperIntegrationTests{}
```

> 默认情况下`@ActiveProfiles`是支持继承父类或者封闭类的配置信息的。你可以完全自定义解析激活配置文件通过实现`ActiveProfilesResolver`，并使用`@ActiveProfiles`的属性`resolver`来注册。  

详情参考[Context Configuration with Environment Profiles](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management-env-profiles) ,[@Nested test class configuration](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-nested-test-configuration) ,以及[@ActiveProfiles](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/ActiveProfiles.html)  

### `@TestPropertySource`
它是一个类级别的注解，你可以使用它来配置属性文件和内联属性的位置，最后添加到`PropertySources`集合中，这个集合在`ApplicationContext`的`Environment`中。  

下面的例子展示了怎样声明一个来自classpath的属性文件:
```java
@ContextConfiguration
@TestPropertySource("/test.properties")
class MyIntegrationTests{}
```

下面的例子展示怎样声明内联属性：
```java
@ContextConfiguraiton
@TestPropertySource(properties = {"timezone = GMT", "port: 4242"})
class MyIntegrationTests{}
```

详情参考[Context Configuration with Test Property Sources](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management-property-sources)  

### `@DynamicPropertySource`
它是一个方法级别的注解，他可以注册动态属性，跟`@TestPropertySource`一样，也是添加到`PropertySources`集合中。当你不能提前判断属性值时，可以通过动态属性来设置-举个例子，如果属性是交由外部资源管理的，比如通过[TestContainers](https://www.testcontainers.org/) 来进行的容器管理。  

下面的例子展示了如何注册一个动态属性：
```java
@ContextConfiguration
class MyIntegrationTests{
    static MyExternalServer server = // ...

    @DynamicPropertySource
    static void dynamicProperties(DynamicPropertyRegistry registry){
        registry.add("server.port",server::getPort);
    }
}
```  

详情参考[Context Configuration with Dynamic Property Sources](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management-dynamic-property-sources)  

### `@DirtiesContext`
这个注解表示底层的Spring`ApplicationContext`在执行测试的时候被污染了（意思就是，测试的时候以某种方式修改或者污染了`ApplicationContext`-比如说，改变单例bean的状态），并且需要关闭这个context。当一个应用上下文被dirty标记，会被测试框架从缓存中移除并关闭。在最后，如果还有其他测试需要这个context，Spring容器会重新构建。  

你可以使用该注解在类级别或者方法级别，在同一个类中或者类的层次结构中。你可以标记`ApplicationContext`是在方法前后还是在类前后被污染的，通过`methodMode`和`classMode`来配置。  

下面的例子展示了几个不同场景的使用方案：

* 在当前的测试类之前，通过声明`classMode`为`BEFORE_CLASS`
```java
@DirtiesContext(classMode = BEFORE_CLASS)
class FetchContextTests{}
```

* 在当前的测试类之后，通过声明`classMode`为`AFTER_CLASS`(默认的classMode)
```java
@DirtiesContext
class FetchContextTests{}
```

* 在当前测试类的每个测试方法之前，通过声明`classMode`为`BEFORE_EACH_TEST_METHOD`
```java
@DirtiesContext(classMode = BEFORE_EACH_TEST_METHOD)
class FreshContextTests{
}
```

* 在当前测试类的每个测试方法执行后，通过声明`classMode`为`AFTER_EACH_TEST_METHOD`
```java
@DirtiesContext(classMode = AFTER_EACH_TEST_METHOD)
class ContextDirtyingTests{}
```

* 在当前测试之前，通过在方法上申明`methodMode`为`BEFORE_METHOD`
```java
@Test
@DirtiesContext(methodMode = BEFORE_METHOD)
void testProcessWhichRequiresFreshAppCtx(){}
```

* 在当前测试之后，通过在方法上声明`methodMode`为`AFTER_METHOD`(默认的方法模式)
```java
@DirtiesContext
@Test
void testProcessWhichDirtiesAppCtx(){}
```

如果`@DirtiesContext`注解修饰的测试context，是`@ContextHierarchy`注解层次结构中的一部分，你可以使用`hierarchyMode`属性去控制context缓存如何清除。默认情况下，一个详尽的算法会用来清除context缓存，包括的不仅是当前层级，还有所有其他共享了同一个父类context的子层级，子层级的所有`ApplicationContext`实例都会从缓存中移除并关闭。在某些情况下，如果你觉得默认的算法清楚的范围太广，你可以指定更简单的当前层级算法：
```java
@ContextHierarchy({
    @ContextConfiguration("/parent-config.xml"),
    @ContextConfiguration("/child-config.xml")
})
class BaseTest{}

class ExtendedTests extends BaseTest{
    @Test
    @DirtiesContext(hierarchyMode=CURRENT_LEVEL)
    void test(){}
}
```

更多关于`EXHAUSTIVE`和`CURRENT_LEVEL`算法的问题，可以参考[DirtiesContext.HierarchyMode](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/annotation/DirtiesContext.HierarchyMode.html)  

### `@TestExecutionListeners`
它定义了用来配置`TestExecutionListener`实现的类级别元数据(`TestExecutionListener`实现是由`TestContextManager`来注册的)。一般来说都是配合`@ContextConfiguration`来使用。  

下面的例子展示了如何注册两个`TestExecutionListener`实现
```java
@ContextConfiguration
@TestExecutionListeners({CustonTestExecutionListener.class,AnotherTestExecutionListerner.class})
class CustomTestExecutionListenerTests {}
```

默认情况下，`@TestExecutionListeners`是支持从父类继承的，或者内部类从外部封闭类继承。详情参考[@Nested test class configuration](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-nested-test-configuration) 和[@TestExecutionListeners javadoc](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/TestExecutionListeners.html)  


### `@Commit`
`@Commit`代表测试方法的事务会在测试方法完成后提交。你可以将`@Commit`替换为`@Rollback(false)`。`@Commit`和`@Rollback`相似，都可以声明在类或方法上。  

使用实例：
```java
@Commit
@Test
void testProcessWithoutRollback(){
}
```

### `@Rollback`
`@Rollback`代表测试方法执行完后，是否回滚事务。为true则回滚，否则事务会提交（跟`@Commit`一样）。该注解的默认值为true，就算没有声明该注解，事务默认也会回滚。  

当申明在类上时，`@Rollback`注解将会影响类的所有测试方法，当申明在方法时，只会影响指定方法，并会覆盖类上的全局`@Rollback`或`@Commit`配置  

使用实例：
```java
@Test
@Rollback(false)
void testProcessWithoutRollback(){
}
```

### `@BeforeTransaction`
它代表注解的`void`方法应该在事务启动之前运行，对测试方法来说，它已经被配置好了在一个事务中运行，是通过使用Spring的`@Transactional`注解来实现的。`@BeforeTransaction`方法是不需要`public`修饰的，并且可以声明在java8的接口默认方法上。  

使用实例：
```java
@BeforeTransaction
void beforeTransaction(){}
```

### `@AfterTransaction`
它代表注解的`void`方法应该在事务结束后运行，对测试方法来说，它已经被配置好了在一个事务中运行，是通过使用Spring的`@Transactional`注解来实现的。`@AfterTransaction`方法是不需要`public`修饰的，并且可以声明在java8的接口默认方法上。
```java
@AfterTransaction
void afterTransaction(){}
```

### `@Sql`
它是用来配置测试类或者方法需要的sql脚本的。  
```java
@Test
@Sql({"/test-schema.sql","/test-user-data.sql"})
void userTest(){}
```
详情参考[Executing SQL scripts declaratively with @Sql](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-executing-sql-declaratively)  

### `@SqlConfig`
它用来配置如何解析和执行`@Sql`注解配置的脚本。  
```java
@Test
@Sql(
    scripts = "/test-user-data.sql",
    config = @SqlConfig(commentPrefix = "`", separator = "@@")
)
void userTest(){}
```

### `@SqlMergeMode`
它是用来设置`@Sql`注解的方法和类的sql脚本是否融合在一起。如果类和方法上都没有`@SqlMergeMode`注解，那么默认的`OVERRIDE`模式将会被使用。在`OVERRIDE`模式下，方法上声明的`@Sql`会覆盖掉类上的`@Sql`声明。  

注意方法上的`@SqlMergeMode`声明会覆盖类上的声明。  

作用在类上：
```java
@SpringJunitConfig(TestConfig.class)
@Sql("/test-schema.sql")
@SqlMergeMode
class UserTests{
    @Test
    @Sql("/user-test-data-001.sql")
    void standardUserProfile(){
    }
}
```

作用在方法上：
```java
@SpringJUnitConfig(TestConfig.class)
@Sql("/test-schema.sql")
class UserTests{
    @Test
    @Sql("/user-test-data-001.sql")
    @SqlMergeMode(MERGE)
    void standardUserProfile(){}
}
```

### `@SqlGroup`
它是一个容器注解，内部集成了多个`@Sql`注解。你可以使用`@SqlGroup`直接声明多个集成的`@Sql`，或者你可以配合java8对重复注解的支持来使用，`@Sql`可以在同一个类和方法上声明多次，隐式的生成注解容器。
```java
@Test
@SqlGroup({
    @Sql(scripts = "/test-schema.sql",config = @SqlConfig(commentPrefix = "`")),
    @Sql("/test-user-data.sql")
})
void userTest(){}
```

## 4.2. 标准注解支持
下面的注解在任何配置的Spring TestContext框架的标准语法中都支持。注意这些注解并不是专门用来测试的，在Spring框架的任何地方都可以使用。  
* `@Autowired`
* `@Qualifier`
* `@Value`
* `@Resource`(javax.annotation)如果JSR-250存在
* `@ManagedBean`(javax.annotation)如果JSR-250存在
* `@Inject`(javax.inject)如果JSR-330存在
* `@Named`(javax.inject)如果JSR-330存在
* `@PersistenceContext`(javax.persistence)如果JPA存在
* `@PersistenceUnit`(javax.persistence)如果JPA存在
* `@Required`
* `@Transactional`(org.springframework.transaction.annotation)[部分属性支持](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-tx-attribute-support)  

> JSR-250生命周期注解  
> 在Spring TestContext框架中，你可以在`ApplicationContext`内部配置的任何应用组件上以标准语法使用`@PostConstruct`和`@PreDestroy`。但是在实际测试类中，这些生命周期注解还是有使用限制的。  
>
> 如果一个方法在测试类中，并且被注解`@PostConstruct`修饰，那么这个方法会在底层测试框架的所有before方法之前执行（举个例子，任何被JUnit Jupiter的`@BeforeEach`注解修饰的方法），并且他会被应用在测试类中的每个测试方法上。另一方面，如果一个方法在测试类中被`@PreDestroy`注解修饰，那么这个方法永远不会运行。所以，在一个测试类中，我们推荐使用来自测试框架的生命周期的回调函数，而不是`@PostConstruct`和`@PreDestroy`。  

## 4.3. Spring JUnit 4 测试注解
下面的注解仅在与 [SpringRunner](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit4-runner) ，[Spring's JUnit 4 rules](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit4-rules) ,或者[Spring’s JUnit 4 support classes](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-support-classes-junit4) 配合使用时才有效：  
* `@IfProfileValue`
* `@ProfileValueSourceConfiguration`
* `@Timed`
* `@Repeat`

### `IfProfileValue`
它代表注解修饰的测试只在指定测试环境生效。如果`ProfileValueSource`的属性`value`跟`name`的值匹配，这个测试才生效。否则，这个测试不会启用。  

你可以声明`IfProfileValue`在类或者方法上。类级别的使用优先于方法级别的使用，特别是针对类下的所有方法或者所有子类的时候。要启用一个测试，他的类和方法都要是启用状态，但是在默认没有声明`IfProfileValue`的情况下，就代表着启用状态。JUnit4的`@Ignore`注解跟它类似，除了`@Ignore`只能用来屏蔽测试。  

使用实例：
```java
@IfProfileValue(name = "java.vendor", value="Oracle Corporation")
@Test
public void testProcessWithRunsOnlyOnOracleJvm(){}
```

另外，你可以为`@IfProfileValue`配置一个`values`集合，就像TestNG在JUnit4环境支持测试组一样：
```java
@Test
@IfProfileValue(name = "test-groups", values={"unit-tests","integration-tests"})
public void testProcessWhichRunsForUnitOrIntegrationTestGroups(){}
```

### `@ProfileValueSourceConfiguration`
它是一个类级别的注解，它指定了当通过`@IfProfileValue`注解检索配置值的时候该使用什么类型的`ProfileValueSource`。如果该注解没有在测试上声明，`SystemProfileValueSource`会被作为默认值。  

使用实例：
```java
@Test
@ProfileValueSourceConfiguration(CustomProfileValueSource.class)
public class CustomProfileValueSourceTests(){}
```

### `@Timed`
`@Timed`代表备注接的测试方法必须在指定的时间段内完成（微秒）。如果测试时间超过了指定的时间段，则测试失败。  

这个时间段包括运行测试方法自身的时间，以及重复测试的时间（`@Repeat`)，也包括其他测试资源的安装和卸载时间。

```java
@Timed(millis = 1000)
public void testProcessWithOneSecondTimeout(){
}
```
Spring的`@Timed`语法跟JUnit4的语法`@Test(timeout=...)`不同，是因为JUnit4处理测试执行超时的处理方式（在单独的一个分支执行测试方法），如果测试超时`@Test(timeout=...)`会立即让测试失败。但Spring的`@Timed`不同，在标识失败之前，他会让测试方法先走完。  

### `@Repeat`
它代表注解的测试方法必定会重复执行。重复执行的次数需要指定在注解参数中  

除了重复执行测试方法本身，测试资源的安装和卸载也会被重复执行。

```java
@Repeat(10)
@Test
public void testProcessRepeatedly(){}
```

## 4.4. Spring JUnit Jupiter 测试注解
下面的注解只在配合`SpringExtension`和JUnit Jupiter(也就是JUnit5的编程模型)使用时才可用
* `@SpringJUnitConfig`
* `@SpringJUnitWebConfig`
* `@TestConstructor`
* `@NestedTestConfiguration`
* `@EnabledIf`
* `@DisabledIf`  

### `@SpringJUnitConfig`
它是一个集成的注解，他是由来自JUnit Jupiter的`@ExtendWith(SpringExtension.class)`和来自Spring TestContext框架的`@ContextConfiguration`组成的。他可以作用在类上以替代`@ContextConfiguration`。关于配置选项，`@ContextConfiguration`和`@SpringJUnitConfig`唯一的区别是在`@SpringJUnitConfig`可以用`value`属性声明组件类。  

下面的例子展示了如何使用`@SpringJUnitConfig`注解指定一个配置类：
```java
@SpringJUnitConfig(TestConfig.class)
class ConfigurationClassJUnitJupiterSpringTests{
}
```

下面的例子展示了如何使用`@SpringJUnitConfig`注解指定一个配置文件的位置：
```java
@SpringJUnitConfig(locations = "/test-config.xml")
class XmlJUnitJupiterSpringTests{
}
```

详情参考[Context Management](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management) 和[@SpringJUnitConfig](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/junit/jupiter/SpringJUnitConfig.html) ，`@ContextConfiguration`的API文档

### `@SpringJUnitWebConfig`
它是一个复合注解，是由来自JUnit Jupiter的`@ExtendWith(SprintExtension.class)`与来自Spring TestContext框架的`ContextConfiguration`、`@WebAppConfiguration`构成。你可以将他申明在类上，它可以用来代替`@ContextConfiguration`和`@WebAppConfiguration`。关于配置选项，`@ContextConfiguration`和`@SpringJUnitWebConfig`的唯一区别是`@SpringJUnitWebConfig`可以同使用`value`属性来声明组件类。另外你可以覆盖`@WebAppConfiguration`的`value`属性，通过`@SpringJUnitWebConfig`的`resourcePath`属性。  

下面的例子展示了如何指定一个配置类：
```java
@SpringJUnitWebConfig(TestConfig.class)
class ConfigurationClassJUnitJupiterSpringWebTests{}
```

下面的例子展示了如何指定一个配置文件的路径：
```java
@SpringJUnitWebConfig(locations = "/test-config.xml")
class XmlJUnitJupiterSpringWebTests{}
```
详情参考[Context Management](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-ctx-management) 和[@SpringJUnitWebConfig](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/junit/jupiter/web/SpringJUnitWebConfig.html) ，[@ContextConfiguration](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/ContextConfiguration.html) ，[@WebAppConfiguration](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/web/WebAppConfiguration.html)     

### TestConstructor
它是一个类级别的注解，用来配置如何将测试的`ApplicationContext`组件参数装配到测试类构造方法的参数中。  

如果`@TestConstructor`不存在，那么会有一个默认的装配模式被使用。下面的提示展示了如何改变默认模式。注意，如果构造器上有一个`@Autowired`注解，那么`@TestConstructor`和默认模式都会被覆盖。  
  
> **改变测试构造方法的默认装配模式**
> 要改变默认的装配模式可以通过设置`spring.test.constructor.autowire.mode`JVM 系统属性为`all`。还可以通过设置`SpringProperties`机制来完成。  
> 
> 从Spring Framework 5.3开始，默认模式可以设置为一个[JUnit Platform configuration parameter](https://junit.org/junit5/docs/current/user-guide/#running-tests-config-params)  
> 
> 如果`spring.test.constructor.autowire.mode`属性没有设置，那么测试类的构造函数将不会自动装配  

> 从Spring Framework 5.2开始，在使用JUnit Jupiter时`TestConstructor`只能和`SpringExtension`配合使用。注意在大多数境况下，`SpringExtension`已经为你自动注册完成了-比如在用了`@SpringJUnitConfig`和`@SpringJUnitWebConfig`或者各种来自Spring Boot测试相关的注解时  


### `@NestedTestConfiguration`
它是一个类级别的注解，被用来设置Spring测试配置注解如何在内部测试类中运行。  

如果它没有在测试类显性申明，在他的父类结构，或者在他的封闭类结构中，默认的封闭配置继承模型会被使用。下面的提示展示如何修改默认模式。  

> **改变默认的封闭配置继承模式**  
> 默认的封闭配置继承模式是`INHERIT`，要改变默认的模式可以通过设置`spring.test.enclosing.configuration`JVM系统属性为`OVERRIDE`.还可以通过`SpringProperties`机制来改变  

支持`@NestedTestConfiguration`语法的Spring测试框架注解：  
* `@BootstrapWith`
* `@ContextConfiguration`
* `@WebAppConfiguration`
* `@ContextHierarchy`
* `@ActiveProfiles`
* `@TestPropertySource`
* `@DiritesContext`
* `@TestExecutionListeners`
* `@Transactional`
* `@Commit`
* `@Rollback`
* `@Sql`
* `@SqlConfig`
* `@SqlMergeMode`
* `@TestContructor`  

> 通常情况下`@NestedTestConfiguration`注解需要和`@Nested`注解结合使用在JUnit Jupiter中才有意义；但是可能有其他Spring支持的测试框架和继承测试类使用了该注解。  

详情参考[@Nested test class configuration ](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-nested-test-configuration)  

### `@EnabledIf`
它表示它修饰的JUnit Jupiter类或者测试方法是否启用，由提供的`expression`结果决定。具体来说，如果一个表达式的计算结果是`Boolean.TRUE`或者一个`String`equal为`true`(忽略大小写)，这个测试就是启用的。当应用于类级别时，所有在该类中的测试方法都会默认启用。  

以下的表达式都可用：  
* [Spring Expression Language](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#expressions) 。举个例子：`@EnabledIf("#{systemProperties\['os.name'].toLowerCase().contains('mac')}")`  
* Spring [Environment](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-environment) 中可用的属性占位符。举个例子：`@EnabledIf("${smoke.tests.enabled}")`  
* 文本。比如：`@EnabledIf("true")`  

注意文本表达式如果不是动态的属性占位符的解析结果，那将没有任何意义，因为`@EnableIf("false")`等于`@Disabled`，并且`@EnabledIf("true")`也没有任何意义。  

你可以将`@EnabledIf`作为一个元注解去创建自定义的复合注解。比如，你可以创建一个自定义的`@EnabledOnMac`注解：  
```java
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@EnabledIf(
    expression = "#{systemProperties['os.name'].toLowerCase().contains('mac')}",
    reason = "Enabled on Mac OS"
)
public @interface EnabledOnMac{}
```

### `@DisabledIf`
它表示它修饰的JUnit Jupiter类或者测试方法是否弃用，由提供的`expression`结果决定。具体来说，如果一个表达式的计算结果是`Boolean.TRUE`或者一个`String`equal为`true`(忽略大小写)，这个测试就是弃用的。当应用于类级别时，所有在该类中的测试方法都会默认弃用。  

以下的表达式都可用：  
* [Spring Expression Language](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#expressions) 。举个例子：`@DisabledIf("#{systemProperties\['os.name'].toLowerCase().contains('mac')}")`  
* Spring [Environment](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#beans-environment) 中可用的属性占位符。举个例子：`@DisabledIf("${smoke.tests.enabled}")`  
* 文本。比如：`@DisabledIf("true")`  

注意文本表达式如果不是动态的属性占位符的解析结果，那将没有任何意义，因为`@DisabledIf("true")`等于`@Disabled`，并且`@EnabledIf("false")`也没有任何意义。  

你可以将`@DisabledIf`作为一个元注解去创建自定义的复合注解。比如，你可以创建一个自定义的`@DisabledOnMac`注解：
```java
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@DisabledIf(
    expression = "#{systemProperties['os.name'].toLowerCase().contains('mac')}",
    reason = "Disabled on Mac OS"
)
public @interface DisabledOnMac {}
```

## 4.5. 测试元注解
你可以使用大多数测试相关的注解作为元注解去创建自定义的复合注解，那样可以减少测试套件的重复配置。  

你可以使用下面任何一个注解作为元注解：  
* @BootstrapWith
* @ContextConfiguration
* @ContextHierarchy
* @ActiveProfiles
* @TestPropertySource
* @DirtiesContext
* @WebAppConfiguration
* @TestExecutionListeners
* @Transactional
* @BeforeTransaction
* @AfterTransaction
* @Commit
* @Rollback
* @Sql
* @SqlConfig
* @SqlMergeMode
* @SqlGroup
* @Repeat (only supported on JUnit 4)
* @Timed (only supported on JUnit 4)
* @IfProfileValue (only supported on JUnit 4)
* @ProfileValueSourceConfiguration (only supported on JUnit 4)
* @SpringJUnitConfig (only supported on JUnit Jupiter)
* @SpringJUnitWebConfig (only supported on JUnit Jupiter)
* @TestConstructor (only supported on JUnit Jupiter)
* @NestedTestConfiguration (only supported on JUnit Jupiter)
* @EnabledIf (only supported on JUnit Jupiter)
* @DisabledIf (only supported on JUnit Jupiter)  

考虑下面的例子：
```java
@RunWith(SpringRunner.class)
@ContextConfiguration({"/app-config.xml","/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
public class OrderRepositoryTests{}

@RunWith(SpringRunner.class)
@ContextConfiguration({"/app-config.xml", "/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
public class UserRepositoryTests{}
```

观察上面的Spring测试注解配置基本都是重复的，可以通过自定义注解合并他们：

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@ContextConfiguration({"/app-config.xml", "/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
public @interface TransactionalDevTestConfig {}
```
然后你就可以直接使用这个自定义注解去简化JUnit4为基础的测试类：  
```java
@RunWith(SpringRunner.class)
@TransactionalDevTestConfig
public class OrderRepositoryTests{}

@RunWith(SpringRunner.class)
@TransactionalDevTestConfig
public class UserRepositoryTests {}
```
如果我们使用JUnit Jupiter进行测试类编写，那么可以进一步减少重复代码，因为JUnit 5的注解同样可以作为元注解：  
```java
@ExtendWith(SpringExtension.class)
@ContextConfiguration({"/app-config.xml", "/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
class OrderRepositoryTest{}

@ExtendWith(SpringExtension.class)
@ContextConfiguration({"/app-config.xml", "/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
class UserRepositoryTests{}
```
观察上面的Spring测试注解配置基本都是重复的，可以通过自定义注解合并他们：
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@ExtendWith(SpringExtension.class)
@ContextConfiguration({"/app-config.xml", "/test-data-access-config.xml"})
@ActiveProfiles("dev")
@Transactional
public @interface TransactionalDevTestConfig { }
```

然后你就可以直接使用这个自定义注解去简化JUnit5为基础的测试类：  
```java
@TransactionalDevTestConfig
class OrderRepositoryTests { }

@TransactionalDevTestConfig
class UserRepositoryTests { }
```
因为JUnit Jupiter支持`@Test`,`@RepeatedTest`,`ParameterizedTest`等等作为源注解，所以你也可以创建基于方法级别的自定义复合注解，比如我们创建一个注解它结合了来自JUnit Jupiter的`@Test`，`@Tag`和来自Spring的`@Transactional`：

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Transactional
@Tag("integration-test") // org.junit.jupiter.api.Tag
@Test // org.junit.jupiter.api.Test
public @interface TransactionalIntegrationTest {
}
```

然后我们可以在任何JUnit Jupiter测试方法上使用它们：  
```java
@TransactionalIntegrationTest
void saveOrder() { }

@TransactionalIntegrationTest
void deleteOrder() { }
```
详情参考[Spring Annotation Programming Model](https://github.com/spring-projects/spring-framework/wiki/Spring-Annotation-Programming-Model)  

# 5. Spring TestContext Framework
Spring TestContext Framework(在`org.springframework.test.context`包下)，提供了通用的，注解驱动的单元和集成测试，并且不跟你的测试框架耦合。TestContext framework更看重约定而不是配置，有合理的默认值，并且你可以通过注解参数来修改它。  

另外对于常见的测试架构：JUnit 4，JUnit Jupiter(JUnit 5)，和TestNG，TestContext framework提供了特定的支持。对于JUnit4和TestNG，spring提供了`abstract`支持类。此外，Spring为JUnit4提供了自定义JUnit`Runner`和自定义JUnit`Rules`，并且为JUnit Jupiter提供了自定义的`Extension`，它们可以让你编写所谓的POJO测试类。POJO测试类就是测试类不需要继承一个特定的类结构，比如`abstarct`父类。  

下面的章节提供了一个TestContext framework的概览。如果你只对使用框架有兴趣，对扩展自定义监听或者自定义加载器不感兴趣的话，可以直接跳过这个章节。  

## 5.1. 关键抽象概念
框架的核心是由`TestContextManager`、`TestContext`、`TestExecutionListener`、和`SmartContextLoader`接口组成。每个测试类都会创建一个`TestContextManager`。反过来，`TestContextManger`管理着一个`TestContext`，这个`TestContext`保存着当前测试的上下文参数。在测试进行中`TestContextManger`同时也更新`TestContext`的状态，并且委托给`TestExecutionListener`的实现，它会通过依赖注入来检测实际测试的运行，管理事务等等。一个`SmartContextLoader`负责为一个给定的测试类加载`ApplicationContext`。详情参考[javadoc](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/package-summary.html)  

### `TestContext`
`TestContext`封装了测试运行所在的上下文（忽略具体的测试框架）并为其所负责的测试实例提供上下文管理和缓存支持。`TestContext`还能委托`SmarkContextLoader`去加载`ApplicationContext`。  

### `TestContextManager`
`TestContextManger`是Spring TestContext Framework的主要切入点，它负责管理一个单独的`TestContext`并且给每个已经注册的`TestExcutionListener`在以下定义良好的测试执行点发送信号：  
* 在任何"before class"或者"before all"方法之前  
* 测试实例的后期处理  
* 在任何"before"或者"before each"方法之前  
* 在测试方法执行之前但在测试初始化之后
* 在测试方法执行之后但在测试销毁之前
* 在任何"after"或者"after each"方法执行之后  
* 在任何"after class"或者"after all"方法执行之后  

### `TestExecutionListener`
`TestExecutionListener`定义了一系列测试监听API，它们又`TestContextManager`注册和发布。详情参考[TestExecutionListener Configuration](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-tel-config)  

### `ContextLoaders`
`ContextLoaders`是一个策略接口为一个Spring TestContext Framework管理的集成测试加载一个`ApplicationContext`。要提供组件类，激活bean定义配置，测试属性资源，上下文结构，和`WebApplicationContext`的支持你应该实现`SmartContextLoader`而不是这个接口。  

`SmartContextLoader`是`ContextLoader`接口的扩展，它接替了原始`ContextLoader`极少的SPI。具体来说，一个`SmartContextLoader`可以选择去处理资源位置，组件类，或者上下文初始化。其次，一个`SmartContextLoader`可以设置启用bean定义配置和上下文加载的测试属性资源。  

Spring提供了下面的实现：  
* `DelegatingSmartContextLoader`：两个默认加载器之一，它委托给内部的一个`AnnotationConfigContextLoader`，一个`GenericXmlContextLoader`，或者一个`GenericGroovyXmlContextLoader`，取决于测试类的配置声明，或者存在的默认位置或者默认配置类。Groovy支持只在classpath目录下有Groovy时才可用。  
* `WebDelegatingSmartContextLoader`:两个默认加载器之一,它委托给内部的一个`AnnotationConfigWebContextLoader`，一个`GenericXmlWebContextLoader`，或者一个`GenericGroovyXmlWebContextLoader`，取决于测试类的配置声明，或者存在的默认位置或者默认配置类。只有在测试类上有`@WebAppConfiguration`存在时，才能使用web`ContextLoader`。Groovy支持只在classpath目录下有Groovy时才可用。  
* `AnnotationConfigContextLoader`:用组件类加载一个标准的`ApplicationContext`  
* `AnnotationConfigWebContextLoader`:用组件类加载一个`WebApplicationContext`  
* `GenericGroovyXmlContextLoader`:用Groovy脚本或者XML配置文件加载一个标准的`ApplicationContext`  
* `GenericGroovyXmlWebContextLoader`:用Groovy脚本或者XML配置文件加载一个`WebApplicationContext`  
* `GenericXmlContextLoader`:用XML资源地址加载一个标准的`ApplicationContext`  
* `GenericXmlWebContextLoader`:用XML资源地址加载一个`WepApplicationContext`  

## 5.2. 引导TestContext Framework
Spring TestContext Framework内部的默认配置对于一般的使用情况已经足够了。但是，有时开发团队或者第三方框架想改变默认的`ContextLoader`，实现自定义的`TestContext`或者`ContextCache`，增加默认的`ContextCustomizerFactory`和`TestExecutionListener`实现集合等等操作。对于这种对TestContext 框架操作的底层的控制，Spring提供了一个引导策略。   

`TestContextBootstrapper`为TestContext框架定义了SPI。一个`TestContextBootstrapper`通过`TextContextManager`被用来为当前测试加载`TestExecutionListener`实现和构建他管理的`TestContext`。你可以通过`@BootstrapWith`为测试类（或者测试类结构）配置一个自定义的引导策略，可以直接使用`@BootstrapWith`或者把它作为一个元注解.如果没有显式的指定`@BootstrapWith`，默认情况下使用`DefaultTestContextBootstrapper`或者`WebTestContextBootstrapper`，取决于`@WebAppConfiguration`是否存在  

因为`TestContextBootstrapper`SPI很可能在未来更改(去适应新需求),我们强烈建议继承`AbstractTestContextBootstrapper`类或者他的某个具体的字类,而不是实现`TestContextBootstrapper`这个接口  

## 5.3. `TestExecutionListener`配置
Spring提供了下面的`TestExecutionListener`实现，他们是被默认注册的，按照下面的顺序：  
* `ServletTestExecutionListener`:为`WebApplicationContext`配置Servlet API模拟。  
* `DirtiesContextBeforeModesTestExecutionListener`:为"before"模式处理`@DirtiesContext`注解。  
* `DependencyInjectionTestExecutionListener`:为测试实例提供依赖注入.  
* `DirtiesContextTestExecutionListener`:为"after"模式处理`@DirtiesContext`注解。  
* `TransactionalTestExecutionListener`:提供默认的rollback的事务测试执行。  
* `SqlScriptsTestExecutionListener`:使用`@Sql`注解时运行配置的SQL脚本.  
* `EventPublishingTestExecutionListener`:为测试的`ApplicationContext`发布测试执行事件(参照[Test Execution Events](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-test-execution-events))  。  

### 注册`TestExecutionListener`实现
你可以为测试类和其字类注册`TestExecutionListener`实现通过使用`@TestExecutionListeners`注解。详情参考[annotation support](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations) ,[@TestExecutionListeners](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/TestExecutionListeners.html)  

### 自动化探索默认的`TestExecutionListener`实现  
通过使用`@TestExecutionListeners`来注册`TestExecutionListener`实现,适合有限测试方案的自定义监听器。如果自定义监听器要跨越整个测试套件,那么他就会变得十分臃肿。解决这个问题需要通过支持自动探索默认的`TestExecutionListener`实现来完成，背后依靠`SpringFactoriesLoader`机制来实现。  

具体来说，`spring-test`模块申明所有的核心默认`TestExecutionListener`实现都在`META-INF/spring.factories`属性文件中的`org.springframework.test.context.TestExecutionListener`key下。第三方框架和开发者可以贡献他们自己的`TestExecutionListener`到默认的监听者列表，同样通过`META-INF/spring.factories`属性文件。  

### `TestExecutionListener`实现的顺序
当TestContext框架发现了默认的`TesetExecutionListener`实现通过前面提到的SpringFactoriesLoader机制，这些初始化的监听器通过spring的`AnnotationAwareOrderComparator`来排序，而它又使用Spring的`Ordered`接口和`@Order`注解来排序。`AbstractTestExecutionListener`和所有默认的`TestExecutionListener`都以适当的值实现了`Ordered`。所以第三方框架和开发者应该确保他们的默认`TestExecutionListener`实现是是implements`Ordered`的或者由`@Order`注解。通过`TestExecutionListener`实现的`getOrder()`方法来查看核心监听器的顺序值。  

### 合并`TestExecutionListener`实现
如果一个自定义`TestExecutionListener`是通过`@TestExecutionListeners`注册的，那么默认的监听器将不会被注册。在大多数测试场景中，这会强制要求开发者手动申明所有默认的监听器加上用户自定义的监听器：  
```java
@ContextConfiguration
@TestExecutionListeners({
    MyCustomTestExecutionListener.class,
    ServletTestExecutionListener.class,
    DirtiesContextBeforeModesTestExecutionListener.class,
    DependencyInjectionTestExecutionListener.class,
    DirtiesContextTestExecutionListener.class,
    TransactionalTestExecutionListener.class,
    SqlScriptsTestExecutionListener.class
})
class MyTest {
    // class body...
}
```
这种方法带来的挑战是，你必须要记得所有的默认监听器。并且每个发布版本的监听器可能改变-举个例子`SqlScriptsTestExecutionListener`是在Spring Framework 4.1引入的，而`DirtiesContextBeforeModesTestExecutionListener`实在Spring Framework 4.2引入的。此外，第三方框架比如Spring Boot和Spring Security通过前面提到的`automatic discovery mechanism`注册了他们自己的默认`TestExecutionListener`实现。  

为了避免记住和重新声明所有默认的监听器，你可以设置`@TestExecutionListeners`的`mergeMode`属性为`MergeMode.MERGE_WITH_DEFAULTS`。这个属性值表实本地申明的监听器应该和默认监听器合并。这个合并算法会移除重复的申明，并且会根据`AnnotationAwareOrderComparator`排序。如果监听器实现了`Ordered`或者由`@Order`注解修饰，那么它可以影响默认监听器的排序。否则，本地声明的监听器会追加到默认监听器列表的末尾。  

举个例子，如果`MyCustomTestExecutionListener`类配置了`order`值（举个例子，500）比`ServletTestExecutionListener`的order值小(恰好是1000)，`MyCustomTestExecutionListener`可以自动合并到默认集合中并在`ServletTestExecutionListener`之前，之前的例子可以替换成下面的代码：  
```java
@ContextConfiguration
@TestExecutionListeners(
    listeners = MyCustomTestExecutionListener.class,
    mergeMode = MERGE_WITH_DEFAULTS
)
class MyTest {
    // class body...
}
```

## 5.4. 测试执行事件
Spring Framework 5.2引入了`EventPublishingTestExecutionListener `，提供了一个实现自定义`TestExecutionListener`的替代方法。在测试`ApplicationContext`中的组件可以通过`EventPublishingTestExecutionListener`监听下列的事件，每个事件对应`TestExecutionListener`API中的一个方法。  
* `BeforeTestClassEvent`
* `PrepareTestInstanceEvent`
* `BeforeTestMethodEvent`
* `BeforeTestExecutionEvent`
* `AfterTestExecutionEvent`
* `AfterTestMethodEvent`
* `AfterTestClassEvent`

> 这些事件只有在`ApplicationContext`已经加载后才发布  

这些事件可能因为多种原因被消费，比如重设模拟bean或者追踪测试执行。选择消费测试执行事件，而不是实现一个自定义`TestExecutionListener`，其中的一个优点是测试执行事件可以被任何在测试`ApplicationContext`中注册的Spring bean消耗，这些bean可以直接受利于依赖注入或者`ApplicationContext`的其他特性。相对应的，在`ApplicationContext`中的`TestExecutionListener`并不是一个bean。  

为了监听测试执行事件，一个Spring bean可以选择去实现`org.springframework.context.ApplicationListener`接口。也可以用`@EventListener`修饰监听方法并且配置监听上面提到的指定事件类型中的一个。因为这个方法的流行，Spring提供了以下专用的`@EventListener`注解去简化测试执行事件监听器的注册。这些注解是在`org.springframework.test.context.event.annotation`包下的。  
* `@BeforeTestClass`
* `@PrepareTestInstance`
* `@BeforeTestMethod`
* `@BeforeTestExecution`
* `@AfterTestExecution`
* `@AfterTestMethod`
* `@AfterTestClass`  

### 异常处理
默认情况下，如果一个测试执行事件监听器在消费事件时抛出了一个异常，这个异常会传递到底层使用的测试框架上（比如JUnit或者TestNG）。比如在消费`BeforeTestMethodEvent`时抛出一个异常，对应的测试方法将会失败。相反，如果一个异步的测试执行事件监听器抛出一个异常，这个异常是不会传递到底层的测试框架的。异步异常处理的详情，查阅类级别`@EventListener`的javadoc。  

### 异步监听器
如果你想要一个特别的测试执行事件监听器去异步处理事件，可以使用Spring的[常规`@Async`支持](https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#scheduling-annotation-support-async) 。详情查阅类级别`@EventListener`的javadoc。  

## 5.5. 上下文管理
每个`TestContext`都为它负责的测试实例提供了上下文管理和缓存支持。测试实例不会自动接收对配置`ApplicationContext`的访问。但是，如果测试类实现了`ApplicationContextAware`接口，会为测试实例提供一个`ApplicationContext`的引用。注意`AbstractJUnit4SpringContextTests`和`AbstractTestNGSpringContextTests`实现了`ApplicationContextAware`，所以自动提供对`ApplicationContext`的访问。  

> **@Autowired ApplicationContext**
> 作为一个实现`ApplicationContextAware`接口的替代方法，你可以通过设置`@Autowired`注解在字段上或者setter方法上来注入application context： 
> ```java
> @SpringJUnitConfig
> class MyTest {
> 
>    @Autowired 
>    ApplicationContext applicationContext;
>
>    // class body...
> }
> ```
> 同样，如果你的测试需要加载一个`WebApplicationContext`:
> ```java
> @SpringJUnitWebConfig
> class MyWebAppTest {
> 
>    @Autowired 
>    WebApplicationContext wac;
>
>    // class body...
> }
> ```
> 通过使用`@Autowired`进行依赖注入是通过`DependencyInjectionTestExecutionListener`来提供的，默认情况下就会对它进行配置(参考[https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-fixture-di](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-fixture-di))  

使用TestContext框架的测试类不需要extends任何特定的类或者实现任何特定接口去配置他们的application context。你只需要在类级别声明一个`@ContextConfiguration`注解即可。如果你的测试类没有显性的声明application context资源位置或者组件类，配置的`ContextLoader`会决定怎样从一个默认的位置或者默认的配置类加载一个context。除了资源位置和组件类，一个application context还可以通过application context初始化程序配置。  

下面的几个章节阐述了怎样使用Srping的`@ContextConfiguration`注解去配置一个测试的`ApplicationContext`通过使用XML配置文件，Groovy脚本，组件类（典型的`@Configuration`类），或者上下文初始化程序。另外，你可以实现并配置你自定义的`SmartContextLoader`为高级的使用场景。  

* Context Configuration with XML resources
* Context Configuration with Groovy Scripts
* Context Configuration with Component Classes
* Mixing XML, Groovy Scripts, and Component Classes
* Context Configuration with Context Initializers
* Context Configuration Inheritance
* Context Configuration with Environment Profiles
* Context Configuration with Test Property Sources
* Context Configuration with Dynamic Property Sources
* Loading a `WebApplicationContext`
* Context Caching
* Context Hierarchies  

### Context Configuration with XML resources
通过XML配置文件为你的测试加载`ApplicationContext`，需要用`@ContextConfiguration`注解修饰你的测试类，并用一个由XML文件位置构成的数组来给`locations`属性赋值。一个相对路径（比如`context.xml`）会被看做一个classpath资源并且会关联到测试类定义的包下。一个以斜线开头的路径会被看作绝对的classpath路径（比如`/org/example/config.xml`）。一个路径代表一个资源URL(比如一个路径的前缀是`classpath:`,`file:`,`http:`,等等)。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from "/app-config.xml" and
// "/test-config.xml" in the root of the classpath
@ContextConfiguration(locations={"/app-config.xml", "/test-config.xml"}) 
class MyTest {
    // class body...
}n
```
`@ContextConfiguration`通过标准的Java`value`属性为`locations`属性提供了一个别名。所以如果你不在`@ContextConfiguration`申明额外的属性，你可以省略`locations`：  
```java
@ExtendWith(SpringExtension.class)
@ContextConfiguration({"/app-config.xml", "/test-config.xml"}) 
class MyTest {
    // class body...
}
```
如果你`locations`和`value`属性都没有声明，那么TestContext框架会尝试检测默认的XML资源路径。具体来说，`GenericXmlContextLoader `和`GenericXmlWebContextLoader `会基于测试类的名称检测资源路径。如果你的类名为`com.example.MyTest`，`GenericXmlContextLoader`会从`classpath:com/example/MyTest-context.xml`加载你的application context。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from
// "classpath:com/example/MyTest-context.xml"
@ContextConfiguration 
class MyTest {
    // class body...
}
```

### Context Configuration with Groovy Scripts
通过使用[Groovy Bean Definition DSL](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#groovy-bean-definition-dsl) 生成的Groovy脚本可以为你的测试生成`ApplicationContext`，配置Groovy的脚本可以通过`@ContextConfiguration`的`locations`和`value`属性来设置Groovy脚本的资源位置。资源查找语法跟XML文件配置一样。  
> **启用Groovy脚本支持**  
> 如果Groovy在classpath路径下，Spring TestContext框架会自动支持用Groovy脚本加载`ApplicationContext`  

```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from "/AppConfig.groovy" and
// "/TestConfig.groovy" in the root of the classpath
@ContextConfiguration({"/AppConfig.groovy", "/TestConfig.Groovy"}) 
class MyTest {
    // class body...
}
```
如果你同时忽略`locations`和`value`属性，测试框架会尝试检测默认的Groovy脚本。具体来说，`GenericGroovyXmlContextLoader`和`GenericGroovyXmlWebContextLoader`会检测一个默认的路径，基于测试类的名称。如果你的类名为`com.example.MyTset`，Groovy上下文加载器会从`classpath:com/example/MyTestContext.groovy`加载上下文。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from
// "classpath:com/example/MyTestContext.groovy"
@ContextConfiguration 
class MyTest {
    // class body...
}
```

> **同时声明XML配置和Groovy脚本**  
> 你可以同时申明XML配置和Groovy脚本通过`@Configuration`脚本的`locations`和`value`属性。如果配置路径以`.xml`路径结尾，`XmlBeanDefinitionReader`会用来加载配置。否则会使用`GroovyBeanDefinitionReader`。  
> ```java
> @ExtendWith(SpringExtension.class)
> // ApplicationContext will be loaded from
> // "/app-config.xml" and "/TestConfig.groovy"
> @ContextConfiguration({ "/app-config.xml", "/TestConfig.groovy" })
> class MyTest {
> // class body...
> }
> ```

### Context Configuration with Component Classes
使用组件类为你的测试加载一个`ApplicationContext`，你可以通过`@ContextConfiguration`注解，并配置`classes`属性：  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from AppConfig and TestConfig
@ContextConfiguration(classes = {AppConfig.class, TestConfig.class}) 
class MyTest {
    // class body...
}
```

> **Component Classes**  
> "Component Class"组件类指的是：  
> * 被`@Configuration`修饰的类
> * 一个组件（就是被`@Component`，`@Service`，`@Repository`，或者其他原始注解修饰的类）  
> * 一个JSR-330编译的类，就是被`javax.inject`注解修饰的类
> * 任何类包含`@Bean`方法
> * 任何其他类尝试去注册为一个Spring组件(就是说一个在`ApplicationContext`里的Spring bean)，可能是利用单个构造方法的自动装配，而不是Spring注解    
> 查看[@Configuration](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/context/annotation/Configuration.html) 和[@Bean](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/context/annotation/Bean.html) 的javadoc查找更多详情。关于注解类的配置和语法，特别注意`@Bean`Lite模式的讨论。  

如果忽略`classes`属性，TestContext框架会尝试检测默认配置类是否存在。具体来说，`AnnotationConfigContextLoader`和`AnnotationConfigWebContextLoader`会检测所有满足配置类实现需求的`static`集成类，详情参考[@Configuration](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/context/annotation/Configuration.html) javadoc。注意配置类的名称是任意的。另外，如果测试类愿意的话他可以包含多个`static`集成配置类。下面的例子里,`OrderServiceTest`类声明了一个`static`集成配置类叫做`Config`，他会被用来为测试类自动加载`ApplicationContext`：  
```java
@SpringJUnitConfig 
// ApplicationContext will be loaded from the
// static nested Config class
class OrderServiceTest {

    @Configuration
    static class Config {

        // this bean will be injected into the OrderServiceTest class
        @Bean
        OrderService orderService() {
            OrderService orderService = new OrderServiceImpl();
            // set properties, etc.
            return orderService;
        }
    }

    @Autowired
    OrderService orderService;

    @Test
    void testOrderService() {
        // test the orderService
    }

}
```

### Mixing XML, Groovy Scripts, and Component Classes
有时候会存在混合XML文件,Groovy脚本，和组件类去配置一个`ApplicationContext`的情况。  

一些第三方框架（比如SpringBoot）对这种混合类型加载提供了良好的支持。但是对Spring框架本身来说，因为之前Spring不支持这种形式的加载，所以在Spring-test模块中，大多数`SmartContextLoader`实现是只支持一种资源类型的。但是，这不意味着你写代码的时候只能用一种类型。`GenericGroovyXmlContextLoader`和`GenericGroovyXmlWebContextLoader`有些不同，他们同时支持XML配置文件和Groovy脚本。此外，第三方框架可以通过`@ContextConfiguration`的属性`locations`和`classes`来实现多类型资源支持，并且，有TestContext框架的标准测试支持，你还可以有如下选项：  

如果你想使用一组资源位置(xml,groovy脚本)和一组`@Configuration`类来配置你的测试，你必须选择一个作为入口，这个入口必须include或者import其他的资源。比如说，在XML或者Groovy脚本中，你可以include`@Configuration`类通过component扫描或者把他们作为一般的Spring Bean定义，反之，在`@Configuration`类中，你可以使用`@ImportResource`去导入XML配置文件或者Groovy脚本。注意这个方式在语义上跟生产配置应用相同：在生产配置中，你可以定义XML或者Groovy资源集合抑或`@Configuration`类集合去加载你的`ApplicationContext`，但是你仍然可以选择include或者import其他类型的配置。  

### Context Configuration with Context Initializers
需要通过初始化程序构造`ApplicationContext`，使用`@ContextConfiguration`注解的`initializers`属性即可，该属性需要一个实现`ApplicationcontextInitializer`类的引用数组。申明初始化构造器之后，他们会被拿来初始化`ConfigurableApplicationContext`。注意每个初始化程序支持的具体`ConfigurableApplicationContext`类型必须跟使用中的`SmartContextLoader`所创建的`ApplicationContext`类型兼容（通常是`GenericApplicationContext`）。此外，初始化程序的调用顺序依赖于他们是否实现了Spring的`Ordered`接口或者以`@Order`注解修饰或者标准的`@Priority`注解。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from TestConfig
// and initialized by TestAppCtxInitializer
@ContextConfiguration(
    classes = TestConfig.class,
    initializers = TestAppCtxInitializer.class) 
class MyTest {
    // class body...
}
```

如果你没有申明任何xml，groovy脚本或者组件类，仅仅声明了初始化程序，那么初始化程序将负责加载context中的bean-举个例子，通过编程方式从xml文件或者配置类中加载bean定义。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be initialized by EntireAppInitializer
// which presumably registers beans in the context
@ContextConfiguration(initializers = EntireAppInitializer.class) 
class MyTest {
    // class body...
}
```

### Context Configuration Inheritance
`@ContextConfiguration`提供了`inheritLocations`和`inheritInitializers`属性来设置当前测试类是否从父类继承 `资源位置`或者`组件类`和初始化程序  

> 从Spring Framework 5.3开始，属性为false，配置信息还是可以从包围类继承  

下面的例子展示了测试类`ExtendedTests`如何按照`base-config.xml`，`extended-config.xml`的顺序加载`ApplicaitonContext`。`extened-config.xml`可以覆盖`base-config.xml`中的bean配置。  
```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from "/base-config.xml"
// in the root of the classpath
@ContextConfiguration("/base-config.xml") 
class BaseTest {
    // class body...
}

// ApplicationContext will be loaded from "/base-config.xml" and
// "/extended-config.xml" in the root of the classpath
@ContextConfiguration("/extended-config.xml") 
class ExtendedTest extends BaseTest {
    // class body...
}
```

组件类也按照同样的加载顺序，覆盖规则也完全一样：  
```java
// ApplicationContext will be loaded from BaseConfig
@SpringJUnitConfig(BaseConfig.class) 
class BaseTest {
    // class body...
}

// ApplicationContext will be loaded from BaseConfig and ExtendedConfig
@SpringJUnitConfig(ExtendedConfig.class) 
class ExtendedTest extends BaseTest {
    // class body...
}
```

下面的例子展示了初始化程序的继承关系，他们的执行顺序跟父子关系无关，参考上一章节对初始化程序执行顺序的描述：  
```java
// ApplicationContext will be initialized by BaseInitializer
@SpringJUnitConfig(initializers = BaseInitializer.class) 
class BaseTest {
    // class body...
}

// ApplicationContext will be initialized by BaseInitializer
// and ExtendedInitializer
@SpringJUnitConfig(initializers = ExtendedInitializer.class) 
class ExtendedTest extends BaseTest {
    // class body...
}
```

### Context Configuration with Environment Profiles
当有多个环境的配置时，Spring提供`@ActiveProfiles`注解，可以让你指定当前激活的环境配置。  

> 你可以在任何`SmartContextLoader`的实现类上使用`@ActvieProfiles`注解，但是旧的`ContextLoader`实现上是不支持的  

下面是一个xml配置和一个`@Configuration`配置类  
```xml
<!-- app-config.xml -->
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:jdbc="http://www.springframework.org/schema/jdbc"
    xmlns:jee="http://www.springframework.org/schema/jee"
    xsi:schemaLocation="...">

    <bean id="transferService"
            class="com.bank.service.internal.DefaultTransferService">
        <constructor-arg ref="accountRepository"/>
        <constructor-arg ref="feePolicy"/>
    </bean>

    <bean id="accountRepository"
            class="com.bank.repository.internal.JdbcAccountRepository">
        <constructor-arg ref="dataSource"/>
    </bean>

    <bean id="feePolicy"
        class="com.bank.service.internal.ZeroFeePolicy"/>

    <beans profile="dev">
        <jdbc:embedded-database id="dataSource">
            <jdbc:script
                location="classpath:com/bank/config/sql/schema.sql"/>
            <jdbc:script
                location="classpath:com/bank/config/sql/test-data.sql"/>
        </jdbc:embedded-database>
    </beans>

    <beans profile="production">
        <jee:jndi-lookup id="dataSource" jndi-name="java:comp/env/jdbc/datasource"/>
    </beans>

    <beans profile="default">
        <jdbc:embedded-database id="dataSource">
            <jdbc:script
                location="classpath:com/bank/config/sql/schema.sql"/>
        </jdbc:embedded-database>
    </beans>

</beans>
```

```java
@ExtendWith(SpringExtension.class)
// ApplicationContext will be loaded from "classpath:/app-config.xml"
@ContextConfiguration("/app-config.xml")
@ActiveProfiles("dev")
class TransferServiceTest {

    @Autowired
    TransferService transferService;

    @Test
    void testTransferService() {
        // test the transferService
    }
}
```

当`TransferServiceTest`运行时，他的`ApplicationContext`会从`app-config.xml`配置文件加载。查看`app-config.xml`你会发现，`accountRepository`有一个`dataSource`bean依赖，但是这个`dataSource`bean没有定义为一个顶级的bean，相反，`dataSource`bean定义了三次，分别在`production`profile，`dev`profile，和`default`profile。  

通过`@ActiveProfiles("dev")`，我们命令Spring启用`{"dev"}`配置信息去加载`ApplicationContext`。最终，会创建一个集成数据库并填充测试数据，并且`accountRepositroy`装配时会带上一个开发的`DataSource`引用。  

当没有明确指定一个profile时，Spring会启用`default`profile。他可以作为一个默认的备用方案。  

下面展示如何使用`@Configuration`替代xml配置：  
```java
@Configuration
@Profile("dev")
public class StandaloneDataConfig {

    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.HSQL)
            .addScript("classpath:com/bank/config/sql/schema.sql")
            .addScript("classpath:com/bank/config/sql/test-data.sql")
            .build();
    }
}
```
```java
@Configuration
@Profile("production")
public class JndiDataConfig {

    @Bean(destroyMethod="")
    public DataSource dataSource() throws Exception {
        Context ctx = new InitialContext();
        return (DataSource) ctx.lookup("java:comp/env/jdbc/datasource");
    }
}
```
```java
@Configuration
@Profile("default")
public class DefaultDataConfig {

    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
            .setType(EmbeddedDatabaseType.HSQL)
            .addScript("classpath:com/bank/config/sql/schema.sql")
            .build();
    }
}
```
```java
@Configuration
public class TransferServiceConfig {

    @Autowired DataSource dataSource;

    @Bean
    public TransferService transferService() {
        return new DefaultTransferService(accountRepository(), feePolicy());
    }

    @Bean
    public AccountRepository accountRepository() {
        return new JdbcAccountRepository(dataSource);
    }

    @Bean
    public FeePolicy feePolicy() {
        return new ZeroFeePolicy();
    }
}
```

```java
@SpringJUnitConfig({
        TransferServiceConfig.class,
        StandaloneDataConfig.class,
        JndiDataConfig.class,
        DefaultDataConfig.class})
@ActiveProfiles("dev")
class TransferServiceTest {

    @Autowired
    TransferService transferService;

    @Test
    void testTransferService() {
        // test the transferService
    }
}
```
上面的例子中将xml配置文件拆分成四个独立的`@Configuration`类：
* `TransferServiceConfig`：使用`@Autowired`注解通过依赖注入获取一个`dataSource`  
* `StandaloneDataConfig`：为开发测试定义一个`dataSource`，它集成了一个数据库  
* `JndiDataCOnfig`：为生产环境定义一个`dataSrouce`，从JNDI检索而得  
* `DefaultDataConfig`：定义一个默认环境，申明了一个集成的数据库  

跟xml配置一样,`TransferServiceTest`同样声明了`@ActiveProfiles("dev")`，但是这次申明了所有组件类。测试类的具体内容没有任何改变。  

通常情况下，配置信心会用在多个测试类上，为了避免重复申明，可以创建一个基类去配置`@ActiveProfiles`注解，以及其他注解配置，然后其他的测试类都实现这个基类：  
> 从Spring Framework 5.3开始，测试配置可以从包围类继承  

```java
@SpringJUnitConfig({
        TransferServiceConfig.class,
        StandaloneDataConfig.class,
        JndiDataConfig.class,
        DefaultDataConfig.class})
@ActiveProfiles("dev")
abstract class AbstractIntegrationTest {
}
```
```java
// "dev" profile inherited from superclass
class TransferServiceTest extends AbstractIntegrationTest {

    @Autowired
    TransferService transferService;

    @Test
    void testTransferService() {
        // test the transferService
    }
}
```

`@ActvieProfiles`注解支持`inheritProfiles`属性，提供一个boolean值就可以配置是否从父类集成配置信息：  
```java
// "dev" profile overridden with "production"
@ActiveProfiles(profiles = "production", inheritProfiles = false)
class ProductionTransferServiceTest extends AbstractIntegrationTest {
    // test body
}
```

此外，有些时候只能用编程的形式解析要激活哪个配置信息，而不是用声明的方式-基于下面这几个方面：  
* 当前的操作系统
* 测试是否运行在一个不断集成构建的服务  
* 是否存在某一环境参数
* 是否存在类级别的自定义注解
* 其他情况  

通过编程的方式解析激活的配置，你需要实现`ActiveProfilesResolver`并且通过`resolver`属性去注册它。更多信息，请参考[javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/ActiveProfilesResolver.html) ：
```java
// "dev" profile overridden programmatically via a custom resolver
@ActiveProfiles(
        resolver = OperatingSystemActiveProfilesResolver.class,
        inheritProfiles = false)
class TransferServiceTest extends AbstractIntegrationTest {
    // test body
}
```
```java
public class OperatingSystemActiveProfilesResolver implements ActiveProfilesResolver {

    @Override
    public String[] resolve(Class<?> testClass) {
        String profile = ...;
        // determine the value of profile based on the operating system
        return new String[] {profile};
    }
}
```

### Context Configuration with Test Property Sources
相对于`@Configuration`配置的`@PropertySource`，你同样可以使用`@TestPropertySource`在测试类上去声明属性资源。这些申明的测试属性资源会被添加到`Environment`中的`PropertySource`集合中，为注解的集成测试类加载`ApplicationContext`。  

> 你可以在任何实现`SmartContextLoader`的类上使用`@TestPropertySource`，但是他不支持在`ContextLoader`的实现上申明。  
> 
> `SmartContextLoader`的实现可以通过`MergedContextConfiguraiton`中的`getPropertySourceLocations()`和`getPropertySourceProperties()`方法来合并测试属性资源值。  

#### 声明测试属性资源
你可以通过`@TestPropertySource`的`locations`和`value`属性来配置测试的属性文件。  

传统的和XML基础的属性文件格式都支持-举个例子`classpath:/com/example/test.properties`或者`file:///path/to/file.xml`  

每个path都会被翻译为一个Spring`Resource`。一个相对路径（比如"test.properties)会被看做一个classpath资源，他指向了当前测试类所在的包。如果一个路径是以斜线开头，会被当做绝对路径（比如："/org/example/test.xml"）。引用了URL的路径（比如说，以`classpath:`，`file:`，或者`http:`开头的路径）会使用指定的资源协议去加载。资源位置通配符（比如`*/.properties`）是不允许的：每个位置必须被解析为一个具体的`.properties`或者`.xml`资源。  

```java
@ContextConfiguration
@TestPropertySource("/test.properties") 
class MyIntegrationTests {
    // class body...
}
```

你可以配置内联属性通过`properties`属性，以key-value的结构赋值，下面的例子会展示如何使用。所有的key-value值对会被添加到包围的`Environment`中，对一个单独测试`PropertySource`它们有最高的优先级。  

key-value值对支持的语法跟java属性文件中的键值定义语法一样：  
* key=value
* key:value
* key value
```java
@ContextConfiguration
@TestPropertySource(properties = {"timezone = GMT", "port: 4242"}) 
class MyIntegrationTests {
    // class body...
}
```

> 从Spring Framework 5.2开始，`@TestPropertySource`可以被用作可重复注解。这意味着你可以为一个测试类声明多次该注解。后面的`@TestPropertySource`的`locations`和`properties`属性会覆盖之前`@TestPropertySource`声明的。  
> 
> 另外，你申明的复合注解里面可能都包含了`@TestPropertySource`，那么所有的`@TestPropertySource`都会为你的测试属性提供资源。  
> 
> 直接声明的`@TestPropertySource`的优先级都会高于复合注解中的声明  

#### 默认属性文件检测
如果`@TestPropertySource`注解的`locations`和`properties`属性都没有声明，那么他会查找一个默认的属性文件，路径基于当前注解修饰的测试类所在位置。比如测试类在`com.example.MyTest`，那么默认的属性文件路径为`classpath:com/example/MyTest.properties`。如果找不到默认文件，那么将会抛出一个`IllegalStateException`。  

#### 优先级
测试配置的属性优先级比操作系环境，java系统，或者任何通过`@PropertySource`或者编程方式声明的属性配置优先级都要高。因此测试属性可以选择性的覆盖所有系统属性和application属性资源。此外，内联属性的优先级是高于资源位置的。但是，有个例外，由`@DynamicPropertySource`申明的属性优先级是高于`@TestPropertySource`的。  

下面的例子中，`timezone`和`port`属性和定义在`/test.properties`中的所有属性会覆盖在系统或者application中相同的属性名称配置。此外如果`/test.properties`中也有`timezone`和`port`属性，那么他们会被由`properties`声明内联属性所覆盖。  
```java
@ContextConfiguration
@TestPropertySource(
    locations = "/test.properties",
    properties = {"timezone = GMT", "port: 4242"}
)
class MyIntegrationTests {
    // class body...
}
```

#### 继承并覆盖测试属性资源
`@TestPropertySource`支持`inheritLocations`和`inheritProperties`属性来设置是否从父类继承配置位置和内联属性信息，这两个参数的默认值都为ture。在值为ture的情况下，就代表可以从父类继承配置信息，并且如果有相同名称的配置，那么后出现的会覆盖之前的。其他的优先级信息跟前面章节提到的一致。  

如果`inheritLocations`和`inheritProperties`属性为false，那么一丝就是不从父类继承配置信息，当前测试类的配置会替代父类的。  

> 从Spring Framework 5.3开始，测试配置可以从环绕类中获取  

下面的例子展示了怎么从父类继承配置资源位置信息：  
```java
@TestPropertySource("base.properties")
@ContextConfiguration
class BaseTest {
    // ...
}

@TestPropertySource("extended.properties")
@ContextConfiguration
class ExtendedTest extends BaseTest {
    // ...
}
```

下面的例子展示了如何从父类继承内联属性：
```java
@TestPropertySource(properties = "key1 = value1")
@ContextConfiguration
class BaseTest {
    // ...
}

@TestPropertySource(properties = "key2 = value2")
@ContextConfiguration
class ExtendedTest extends BaseTest {
    // ...
}
```

### Context Configuration with Dynamic Property Sources
从Spring Framework 5.2.5版本开始，TestContext 框架通过`@DynamicPropertySource`注解提供了动态属性的支持。这个注解可以在继承测试类需要动态资源属性的时候提供帮助。

相对于







