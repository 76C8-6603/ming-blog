---
    title: "Spring集成测试"
    date: 2017-09-15
    tags: ["spring","unit-test","junit4","junit5","testng","mockmvc"]
    
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
它是一个复合注解，是由来自JUnit Jupiter的`@ExtendWith(SprintExtension.class)`与来自Spring TestContext框架的`ContextConfiguration`、`@WebAppConfiguration`构成。你可以将他申明在类上，它可以用来代替`@ContextConfiguration`和`@WebAppConfiguration`。关于配置选项，`@ContextConfiguration`和`@SpringJUnitWebConfig`的唯一区别是`@SpringJUnitWebConfig`可以使用`value`属性来声明组件类。另外你可以覆盖`@WebAppConfiguration`的`value`属性，通过`@SpringJUnitWebConfig`的`resourcePath`属性。  

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

相对于作用在类级别的`@TestPropertySource`，`@DynamicPropertySource`只能作用在静态方法上，并且该方法必须有一个`DynamicPropertyRegistry`参数，这个参数被用来向`Environment`添加 name-value 格式的数据。这些动态的参数值都是通过一个`Supplier`来提供的，它只有在属性被解析的时候才会调用。通常来说，方法引用就是被用来提供参数的，就像下面的例子一样，使用TestContainers项目去管理一个在Spring `ApplicationContext`之外的Redis container。通过`redis.host`和`redis.port`属性，让redis容器管理的ip和host也对test`ApplicationContext`的组件可用。这些属性可以通过Spring的`Environment`抽象访问或者直接在Spring管理的组件中注入-举个例子，分别通过`@Value("${redis.host}")`和`@Value("${redis.port}")`赋值  

> 如果你的`@DynamicPropertySource`声明在基类，并且子类测试失败，因为属性值在子类之中已经被改变。那么你需要在基类上声明`@DirtiesContext`，以确保每个子类的`ApplcationContext`都有正确的属性值  

```java
@SpringJUnitConfig(/* ... */)
@Testcontainers
class ExampleIntegrationTests {

    @Container
    static RedisContainer redis = new RedisContainer();

    @DynamicPropertySource
    static void redisProperties(DynamicPropertyRegistry registry) {
        registry.add("redis.host", redis::getContainerIpAddress);
        registry.add("redis.port", redis::getMappedPort);
    }

    // tests ...

}
```

#### 优先级
动态属性拥有最高的优先级，意思就是会覆盖来自`@TestPropertySource`、操作系统环境、java系统属性、或者通过`@PropertySource`和编码方式申明的属性。因为他的高优先级特性，可以用来覆盖指定的属性值。  

### Loading a WebApplicationContext
如果你需要的上下文对象是`WebApplcationContext`而不是`ApplicationContext`，那你需要在每个测试类上声明`@WebAppConfiguration`注解。  

在TestContext框架为你的测试类生成`WebApplicationContext`时，会在后台为你的`WebApplicationContext`提供一个`MockServletContext`。默认情况下，`MockServletContext`的基础资源路径被设定为`src/main/webapp`。这个相对路径跟JVM的根路径关联（一般来说就是你的项目路径）。如果你熟悉maven项目的Web应用目录结构，你肯定知道WAR根目录的默认位置就是`src/main/webapp`。你可以提供自定义路径去覆盖默认的（`@WebAppConfiguration("src/test/webapp")`）。如果你想引用的基础资源路径是来自classpath而不是文件系统，可以使用Spring的`classpath:`前缀。  

注意Spring测试对`WebApplicationContext`实现的支持等同于对`ApplicationContext`实现的支持。这句话的意思就是`ApplicationContext`可用的注解，`WebaApplicationContext`同样可用，并且使用方式也一样-例如：`@Configuration`、`@ContextConfiguration`、`@ActiveProfiles`、`@TestExecutionListeners`、`@Sql`、`@Rollback`，等等其他注解。  

下面例子展示如果加载`WebApplicationContext`。第一个例子展示默认配置：  
```java
@ExtendWith(SpringExtension.class)

// defaults to "file:src/main/webapp"
@WebAppConfiguration

// detects "WacTests-context.xml" in the same package
// or static nested @Configuration classes
@ContextConfiguration
class WacTests {
    //...
}
```
如果`@WebAppConfiguration`没有指定一个基础资源路径，那么默认的`file:src/main/webapp`路径将会使用。同样的，如果申明`@ContextConfiguration`没有指定资源`locations`，组件类，或者context`initializers`，Spring会尝试在当前测试类的所在路径检测`WacTests-context.xml`文件，或者静态集成的`@Configuration`类。  

下面的例子展示了如何清晰的声明一个`@WebAppConfiguration`基础资源路径，和`@ContextConfiguration`的XML资源路径：  
```java
@ExtendWith(SpringExtension.class)

// file system resource
@WebAppConfiguration("webapp")

// classpath resource
@ContextConfiguration("/spring/test-servlet-config.xml")
class WacTests {
    //...
}
```
这里有个重要的事情需要注意，默认情况下，`@WebAppConfiguration`资源路径是以文件系统为基础的，然而`@ContextConfiguration`资源路径是以classpath为基础的。  

下面展示了如果通过Spring前缀改变默认的路径语法：  
```java
@ExtendWith(SpringExtension.class)

// classpath resource
@WebAppConfiguration("classpath:test-web-resources")

// file system resource
@ContextConfiguration("file:src/main/webapp/WEB-INF/servlet-config.xml")
class WacTests {
    //...
}
```

#### Web Mocks
为了提供完整的测试支持，TestContext框架默认启用了`ServletTestExecutionListener`。当在测试一个`WebApplcationContext`时，`TestExecutionListener`在每个测试方法之前，通过Spring Web的`RequestContextHolder`配置好默认的线程本地状态，并且基于`@WebAppConfiguration`配置的基础资源路径创建`MockHttpServletRequest`，`MockHttpServletResponse`，和`ServletWebRequest`。`ServletTestExecutionListener`同时也确保了`MockHttpServletRequest`和`MockHttpServletResponse`能够注入到测试实例当中，当测试完毕，他会清空线程本地状态。  

下面的实例展示了那些mock对象可以注入到你的测试实例当中。注意`WebApplicationContext`和`MockServletContext`都是被缓存起来的通用测试对象，然而其他的mock对象都是每个测试方法维护一个，其中的逻辑是通过`ServletTestExecutionListener`来实现的。  

```java
@SpringJUnitWebConfig
class WacTests {

    @Autowired
    WebApplicationContext wac; // cached

    @Autowired
    MockServletContext servletContext; // cached

    @Autowired
    MockHttpSession session;

    @Autowired
    MockHttpServletRequest request;

    @Autowired
    MockHttpServletResponse response;

    @Autowired
    ServletWebRequest webRequest;

    //...
}
```

### Context Caching
一旦TestContext框架为一个测试加载了`ApplicationContext`(或者`WebApplicationContext`)，这个上下文对象会被缓存并且在接下来的测试中复用。测试的上下文对象是否从缓存中读取，要看他是否申明了相同`唯一`的上下文配置，并且是在同一个`测试套件`中。要了解测试框架的缓存机制，就必须知道`唯一`和`测试套件`分别代表了什么。  

Spring测试框架会根据context的配置参数生成一个唯一的key值。下面是影响这个key值的配置参数：  
* locations (from @ContextConfiguration)
* classes (from @ContextConfiguration)
* contextInitializerClasses (from @ContextConfiguration)
* contextCustomizers (from ContextCustomizerFactory) – 这个包含了`@DynamicPropertySource`的方法以及Spring Boot支持的测试特性，比如`@MockBean`和`@SpyBean`  
* contextLoader (from @ContextConfiguration)
* parent (from @ContextHierarchy)
* activeProfiles (from @ActiveProfiles) 
* propertySourceLocations (from @TestPropertySource)
* propertySourceProperties (from @TestPropertySource)
* resourceBasePath (from @WebAppConfiguration)  

举个例子，`TestClassA`根据`@ContextConfiguration`的属性`{"app-config.xml", "test-config.xml"}`初始化了context，接下来测试框架会加载该`ApplicationContext`并且根据前面的路径生成一个key，保存到`static`上下文缓存中。如果`TestClassB`同样申明了`{"app-config.xml", "test-config.xml"}`，并且没有`@WebAppConfiguration`，不一样的`ContextLoader`，不一样的启用配置， 不一样的上下文初始化程序，不一样的测试属性资源，或者不一样的父上下文类，那么这两个类就会共享同一个`ApplicationContext`。  

> **测试套件和分支进程**  
> Spring测试框架缓存上下文对象在一个静态的参数里，意思就是如果测试类来自两个不同的进程，就算满足上面两个条件，缓存机制也不可能生效。  
> 
> 因此如果想利用Spring测试的上下文缓存机制，必须确保在同一个进程或者同一个测试套件中。同样，如果通过build框架执行的测试，比如Ant，Maven，或者Gradle，必须确保build框架在测试之间没有fork。比如说，Maven Surefire插件的`forkMode`如果设置为`always`或者`pertest`，那么上下文缓存就不会生效。  

上下文缓存的最大个数是32个。当达到最大值时，一个`最近使用最少`(LRU)的驱逐策略将会被使用来驱逐和关闭陈旧的上下文。想配置缓存的最大数量，可以通过命令行或者JVM系统属性的构建脚本，名字叫`spring.test.context.cache.maxSize`。或者通过编程的方式使用`SpringProperties`设置相同的属性。  

缓存多个应用上下文在给定测试套件中会造成测试套件无意义的长时间运行，当然最好是能知道目前有多少个上下文缓存。通过设置`org.springframework.test.context.cache`的log等级为`DEBUG`即可实现。  

极少数情况测试会污染上下文对象（比如修改bean的定义或者上下文对象的状态），你可以使用`@DirtiesContext`注解来表示下次测试运行之前重载上下文。这个注解是`DirtiesContextBeforeModesTestExecutionListener`和`DirtiesContextTestExecutionListener`提供的，他们两个都是默认启用。  

### Context Hierarchies
有时候需要用到上下文的层次结构，比如说在开发Spring MVC Web应用的时候，你需要一个由Spring`ContextLoaderListener`加载的根`WebApplicationContext`，和一个由Spring`DispatcherServlet`加载的子`WebApplicationContext`。由根对象的申明的组件和基础配置会在子对象中通过web指定的组件去调用。  

`@ContextHierarchy`注解可以申明context的层次结构。如果一个层次结构中的多个类都有该注解，那么你可以合并或者覆盖指定的并已命名的层级。当需要合并一个给定层级的配置时，他们的资源类型必须一样（XML，或者组件类），否则将会被视为两个层级。  

下面的例子是以JUnit Jupiter为基础的，展示了需要使用上下文层次的常见场景。
#### 单个类有上下文层次
`ControllerIntegrationTests`展示了一个典型的Spring MVC web应用的测试场景，申明的上下文层次包含两个层级，一个是根`WebApplicaitonContext`，另外一个是dispatcher servlet`WebApplicationContext`。测试类中的`wac`参数，注入的是上下文层次结构中最后的那一个。  
```java
@ExtendWith(SpringExtension.class)
@WebAppConfiguration
@ContextHierarchy({
    @ContextConfiguration(classes = TestAppConfig.class),
    @ContextConfiguration(classes = WebConfig.class)
})
class ControllerIntegrationTests {

    @Autowired
    WebApplicationContext wac;

    // ...
}
```

#### 类层次中有隐式的父context
下面的例子展示了父子类的层次结构，一共会加载三个上下文对象， 每个子类上下文都是基于父类上下文：  
```java
@ExtendWith(SpringExtension.class)
@WebAppConfiguration
@ContextConfiguration("file:src/main/webapp/WEB-INF/applicationContext.xml")
public abstract class AbstractWebTests {}

@ContextHierarchy(@ContextConfiguration("/spring/soap-ws-config.xml"))
public class SoapWebServiceTests extends AbstractWebTests {}

@ContextHierarchy(@ContextConfiguration("/spring/rest-ws-config.xml"))
public class RestWebServiceTests extends AbstractWebTests {}
```

#### 类层次中有合并的上下文层次配置
下面的例子展示了如何通过指定层级名称去合并上下文配置。一共会加载三个上下文对象，一个是`parent`，一个是父类`child`，还有一个是父类和子类`child`层级之和。  
```java
@ExtendWith(SpringExtension.class)
@ContextHierarchy({
    @ContextConfiguration(name = "parent", locations = "/app-config.xml"),
    @ContextConfiguration(name = "child", locations = "/user-config.xml")
})
class BaseTests {}

@ContextHierarchy(
    @ContextConfiguration(name = "child", locations = "/order-config.xml")
)
class ExtendedTests extends BaseTests {}
```

#### 类层次中有覆盖上下文层次配置
相对于上一个例子，下面要展示的是如果覆盖父类的层级配置。通过设定`@ContextConfiguration`的参数`inheritLocations`为`false`，即可让子类覆盖`child`层级的配置，并同时继承`parent`层级。  
```java
@ExtendWith(SpringExtension.class)
@ContextHierarchy({
    @ContextConfiguration(name = "parent", locations = "/app-config.xml"),
    @ContextConfiguration(name = "child", locations = "/user-config.xml")
})
class BaseTests {}

@ContextHierarchy(
    @ContextConfiguration(
        name = "child",
        locations = "/test-user-config.xml",
        inheritLocations = false
))
class ExtendedTests extends BaseTests {}
```

> 如果你在测试中使用`@DirtiesContext`，并且对应的上下文对象还在一个上下文层级结构中，那么你可以通过`hierarchyMode`去控制上下文缓存如何清理，详情参考[@DirtiesContext in Spring Testing Annotations](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#spring-testing-annotation-dirtiescontext) 和[@DirtiesContext](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/annotation/DirtiesContext.html)  

## 5.6. 测试资源的依赖注入
当你使用`DependencyInjectionTestExecutionListener`（默认配置），测试实例中的依赖会从上下文中的bean中注入。你可以使用setter注入，字段注入，或者两者同时存在，取决于你选择哪个注解和你是否要将他们放进setter方法。如果使用JUnit Jupiter你还可以选择构造器注入。为了跟Spring的基于注解的注入支持保持一致，你还可以使用`@Autowired`注解或者`@Inject`注解来自JSR-330申明在字段或者setter上。  

> 对于JUnit Jupiter以外的测试框架，TestContext框架是不参与测试类的初始化的。因此，如果使用`@Autowired`或者`@Inject`在构造器上，将不会有任何效果  

> 虽然生产代码不鼓励使用字段注入，但是在测试代码中没有这个提议。其中差别的原理是因为你永远不会直接实例化你的测试类。因此，没必要保证能够调用测试类的`public`构造或者setter方法。  

因为`@Autowired`是根据类型的自动装配，如果你有多个bean定义了相同的类型，那么你就无法通过这种方式获取正确的bean。 这种情况下，你可以搭配`@Qualifier`使用`@Autowired`。或者使用`@Inject`搭配`@Named`使用。另外，如果你的测试可以访问他的`ApplicationContext`，你可以直接查找对应bean：`applicationContext.getBean("titleRepository",TitleRepository.class)`。  

如果你不想依赖注入应用到你的测试实例上，不在字段或者setter方法上使用`@Autowired`或者`@Inject`。你可以整个关掉依赖注入，通过直接配置`@TestExecutionListeners`，并且在监听器集合中省略`DependencyInjectionTestExecutionListener.class`。  

考虑测试类中调用`HibernateTitleRepository`类访问数据库的场景，下面的例子通过依赖注入实现了测试。他们的上下文配置在所有的样例代码之后。  

> 下面的依赖注入行为不是JUnit Jupiter特有的，所有支持的测试框架都能适配。  
> 
> 下面例子中调用的静态断言方法，省略了`import`  

`@Autowired` field
```java
@ExtendWith(SpringExtension.class)
// specifies the Spring configuration to load for this test fixture
@ContextConfiguration("repository-config.xml")
class HibernateTitleRepositoryTests {

    // this instance will be dependency injected by type
    @Autowired
    HibernateTitleRepository titleRepository;

    @Test
    void findById() {
        Title title = titleRepository.findById(new Long(10));
        assertNotNull(title);
    }
}
```

`@Autowired` setter
```java
@ExtendWith(SpringExtension.class)
// specifies the Spring configuration to load for this test fixture
@ContextConfiguration("repository-config.xml")
class HibernateTitleRepositoryTests {

    // this instance will be dependency injected by type
    HibernateTitleRepository titleRepository;

    @Autowired
    void setTitleRepository(HibernateTitleRepository titleRepository) {
        this.titleRepository = titleRepository;
    }

    @Test
    void findById() {
        Title title = titleRepository.findById(new Long(10));
        assertNotNull(title);
    }
}
```

上面的测试类用了相同的XML上下文文件（repository-config.xml）：
```java
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- this bean will be injected into the HibernateTitleRepositoryTests class -->
    <bean id="titleRepository" class="com.foo.repository.hibernate.HibernateTitleRepository">
        <property name="sessionFactory" ref="sessionFactory"/>
    </bean>

    <bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
        <!-- configuration elided for brevity -->
    </bean>

</beans>
```

> 如果你继承了一个Spring提供的测试基类，刚好它使用了`@Autowired`在一个setter方法上，那么影响的类型可能有多个bean定义在你的应用上下文中（举个例子，多个`DataSource`bean）。在这种情况下，你可以重写setter方法并且使用`@Qualiifier`注解去指明一个特定的目标bean，就像下面的例子一样（但也确保委托给超类中的重写方法）：
> ```java
> @Autowired
> @Override
> public void setDataSource(@Qualifier("myDataSource") DataSource dataSource) {
>   super.setDataSource(dataSource);
> }
> ```  
> 
> 指定的qualifier值代表要注入的那个目标`DataSource`bean。它的值匹配的是<bean>定义中的<qualifier>申明。Bean的名称被用作后备的`qualifier`值，因此也可以用来有效的指向特定的Bean（Bean id）。  

## 5.7. 测试Request和Session范围的bean
从早期开始Spring就一直支持Request和Session范围的bean，你可以根据下面的步骤来测试你的request范围和session范围的bean：  
* 确保你的测试类被`@WebAppConfiguration`注解修饰。  
* 注入模拟request或者session到你的测试实例中，并且根据需要准备你的测试资源。  
* 通过依赖注入调用`WebApplicationContext`中配置的web组件。  
* 对模拟对象进行断言。  

下面的代码片段是一个用户登录案例的XML配置。注意`userService`bean有一个request范围的`loginAction`bean依赖。并且，`LoginAction`通过使用`SpEL`表达式初始化，表达式从HTTP请求中获取用户名和密码。在我们的测试中，我们希望通过TestContext框架的mock管理来配置这些请求参数。下面首先是配置xml：  
```xml
<beans>
    <bean id="userService" class="com.example.SimpleUserService"
            c:loginAction-ref="loginAction"/>
    <bean id="loginAction" class="com.example.LoginAction"
            c:username="#{request.getParameter('user')}"
            c:password="#{request.getParameter('pswd')}"
            scope="request">
        <aop:scoped-proxy/>
    </bean>
</beans>
```

在下面的`RequestScopedBeanTests`类中，我们同时注入了`UserService`和`MockHttpServletRequest`到我们的测试实例中。在`requestScope()`测试方法中，我们通过设置`MockHttpServletRequest`中的request参数来配置我们的测试资源。当`userService`的`loginUser()`方法被调用时，我们可以确定service中访问的`loginAction`是当前`MockHttpServletRequest`范围中的。
```java
@SpringJUnitWebConfig
class RequestScopedBeanTests {

    @Autowired UserService userService;
    @Autowired MockHttpServletRequest request;

    @Test
    void requestScope() {
        request.setParameter("user", "enigma");
        request.setParameter("pswd", "$pr!ng");

        LoginResults results = userService.loginUser();
        // assert results
    }
}
```

下面的代码片段跟之前的请求范围的bean类似。但是，这次`userService`bean有了一个session范围的依赖`userPreferences`bean。注意这个`UserPreferences`bean通过一个SpEL表达式初始化，它从HTTP session中获取了主题参数。在我们的测试中，需要配置mock session的主题参数。  
```xml
<beans>

    <bean id="userService" class="com.example.SimpleUserService"
            c:userPreferences-ref="userPreferences" />

    <bean id="userPreferences" class="com.example.UserPreferences"
            c:theme="#{session.getAttribute('theme')}"
            scope="session">
        <aop:scoped-proxy/>
    </bean>

</beans>
```

在下面的`SessionScopedBeanTests`类中，我们同时注入`UserService`和`MockHttpService`到我们的测试实例当中。在`sessionScope()`方法中，我们通过设置`MockHttpSession`中的`theme`属性来配置我们的测试资源，我们可以确定service内部调用的`userPreferences`是当前`MockHttpSession`范围中的。  
```java
@SpringJUnitWebConfig
class SessionScopedBeanTests {

    @Autowired UserService userService;
    @Autowired MockHttpSession session;

    @Test
    void sessionScope() throws Exception {
        session.setAttribute("theme", "blue");

        Results results = userService.processUserPreferences();
        // assert results
    }
}
```

## 5.8. 事务管理
在TestContext框架中，事务管理是在`TransactionalTestExecutionListener`中的，并且它是默认配置，即使你不显式的在你的测试类上申明`@TestExecutionListeners`。为了开启事务支持，你必须配置一个`PlatformTransactionManager`bean在`ApplicationContext`中，它是随着`@ContextConfiguration`语法加载的（详情参考下文）。另外，你必须申明`@Transactional`注解在测试类或者方法上。  

### 5.8.1. 测试管理的事务
测试管理的是事务指的是通过使用`TransactionalTestExecutionListener`申明管理的或者是编程方式通过`TestTransaction`。你不应该将它和Spring管理的事务混淆（直接由Spring管理的在测试类的`ApplicationContext`中的事务），或者应用管理的事务混淆（测试中调用的通过编码方式直接管理的在应用代码中的事务）。Spring管理的事务和应用管理的事务通常都可以参与到测试管理的事务当中。但是，当Spring管理或者应用管理的事务配置的是任何传播类型，而不是`REQUIRED`或者`SUPPORTS`类型时，需要特别小心（详情参考[ transaction propagation](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#tx-propagation)  

> **抢占式超时和测试管理的事务**  
> 当使用来自测试框架任何形式的抢占式超时和Spring的测试管理事务配合使用时一定要小心。    
> 典型的就是，Spring测试支持绑定事务状态到当前的线程上（通过一个`java.lang.ThreadLocal`参数）在当前的测试方法执行之前。如果测试框架为了支持抢占式超时，在一个新的线程调用当前的测试方法，那么在当前测试方法中的任何action都不会在测试管理的事务当中被调用。结果就是，测试管理的事务不会回滚任何action。相对的，这些action会被提交到持久储存中。  
> 
> 下面就是可能引起这种问题的情形，但并不是全部：  
> * JUnit 4的`@Test(timeout = ...)`支持和`TimeOut`规则。  
> * JUnit Jupiter 在`org.junit.jupiter.api.Assertions`类中的`assertTimeoutPreemptively(...)`方法。  
> * TestNG的`@Test(timeOut=...)`支持  

### 5.8.2 启用和关闭事务
用`@Transactional`修饰一个测试方法，可以让测试在事务中运行，默认情况下，该事务会在测试完成后自动回滚。如果测试类被`@Transactional`修饰，类层次结构中的所有方法都会在事务中运行。测试方法如果没有被`@Transactional`注解修饰（在类或者方法上），那么测试就不会在事务中运行。注意`@Transactional`不支持测试生命周期方法——比如说，方法有Jupiter的`@BeforeAll`，`@BeforeEach`，等等。此外，测试有`@Transactional`注解但是`propagation`属性是`NOT_SUPPORTED`或者`NEVER`，方法也不会在事务中运行。  

`@Transactional`属性支持  

|属性|是否支持测试管理的事务|
|---|---|
|`value`和`transactionManager`|yes|
|`propagation`|只有`Propagation.NOT_SUPPORTED`和`Propagation.NEVER`支持|
|`isolation`|no|
|`timeout`|no|
|`readOnly`|no|
|`rollbackFor`和`rollbackForClassName`|no:使用`TestTransaction.flagForRollback()`替代|
|`noRollbackFor`和`noRollbackForClassName`|no:使用`TestTransaction.flagForCommit()`代替|  

> 方法级别的生命周期函数——举个例子，被JUnit jupiter的`@BeforeEach`或者`@AfterEach`注解修饰的——是运行在测试管理的事务中的。另一方法，suite级别和类级别的生命周期方法——举个例子，被JUnit Jupiter的`@BeforeAll`或者`AfterAll`注解修饰的和被TestNG的`@BeforeSuite`，`@AfterSuite`，`@BeforeClass`，或者`@AfterClass`注解修饰的方法——是不会运行在测试管理的事务当中的。  
> 
> 如果你需要在事务中运行suit级别或者类级别的生命周期方法，你可以注入对应的`PlatformTransactionManager`到你的测试类中，然后和`TransactionTempalte`一起使用，通过编码的方式实现事务管理。  

注意，`AbstractTransactionalJUnit4SpringContextTests`和`AbstractTransactionalTestNGSpringContextTests`在类级别已经预配置了事务的支持。  

下面的例子展示了一个常用的场景：为一个Hibernate为基础的`UserRepository`写一个集成测试。  
```java
@SpringJUnitConfig(TestConfig.class)
@Transactional
class HibernateUserRepositoryTests {

    @Autowired
    HibernateUserRepository repository;

    @Autowired
    SessionFactory sessionFactory;

    JdbcTemplate jdbcTemplate;

    @Autowired
    void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    @Test
    void createUser() {
        // track initial state in test database:
        final int count = countRowsInTable("user");

        User user = new User(...);
        repository.save(user);

        // Manual flush is required to avoid false positive in test
        sessionFactory.getCurrentSession().flush();
        assertNumUsers(count + 1);
    }

    private int countRowsInTable(String tableName) {
        return JdbcTestUtils.countRowsInTable(this.jdbcTemplate, tableName);
    }

    private void assertNumUsers(int expected) {
        assertEquals("Number of rows in the [user] table.", expected, countRowsInTable("user"));
    }
}
```
这里是不需要在createUser()方法执行后再去清理数据库的，因为任何改变都会通过`TransactionalTestExecutionListener`自动回滚。  

### 5.8.3. 事务回滚和提交行为
默认情况下，测试执行完成后会默认回滚；但是事务提交和回滚是可以配置的，通过`@Commit`和`@Rollback`注解。  

### 5.8.4. 手写事务管理
你可以通过在`TestTransaction`中的静态方法来以编码的方式管理事务。举个例子，你可以在测试方法，before方法，和after方法中start或者end当前测试管理的事务或者说rollback或者commit当前测试管理的事务。每当`TransactionalTestExecutionListener`启用，`TestTransaction`就是自动支持的。  

下面的例子展示了`TestTransaction`的部分特征，详情参考[TestTransaction](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/transaction/TestTransaction.html)  
```java
@ContextConfiguration(classes = TestConfig.class)
public class ProgrammaticTransactionManagementTests extends
        AbstractTransactionalJUnit4SpringContextTests {

    @Test
    public void transactionalTest() {
        // assert initial state in test database:
        assertNumUsers(2);

        deleteFromTables("user");

        // changes to the database will be committed!
        TestTransaction.flagForCommit();
        TestTransaction.end();
        assertFalse(TestTransaction.isActive());
        assertNumUsers(0);

        TestTransaction.start();
        // perform other actions against the database that will
        // be automatically rolled back after the test completes...
    }

    protected void assertNumUsers(int expected) {
        assertEquals("Number of rows in the [user] table.", expected, countRowsInTable("user"));
    }
}
```

### 5.8.5. 在一个事务之外运行代码
有些时候，你可能需要在事务测试方法之前或者之后运行代码，并且在事务上下文之外——举个例子，在运行测试之前验证初始化数据库的状态，或者在运行测试之后验证预期的事务提交行为。`TransactionalTestExecutionListener`为这种场景提供了`@BeforeTransaction`和`@AfterTransaction`注解。你可以把他们中的一个用在测试类的`void`方法上，或者测试接口的任何default`void`方法，然后`TransactionalTestExecutionListener`确保方法在合适的时间运行。  

> 任何before方法(比如JUnit Jupiter的`@BeforeEach`)和任何after方法（比如JUnit Jupiter的`@AfterEach`）是运行在一个事务中的。此外，被`@BeforeTransaction`或者`@AfterTransaction`修饰的方法，不会在没有事务的测试方法执行流程中运行。  

### 5.8.6. 配置一个事务管理器
`TransactionalTestExecutionListener`是期望在测试的`ApplicationContext`中有一个`PlatformTransactionManager`的。如果在测试的`ApplicationContext`中有多个`PlatformTransactionManager`bean，你可以通过`@Transactional("myTxMgr")`申明qualifier，或者`@Transactional(transactionManager = "myTxMgr")`，或者`TransactionManagementConfigurer`的`@Configuration`类实现。详情参考[javadoc for TestContextTransactionUtils.retrieveTransactionManager()](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/transaction/TestContextTransactionUtils.html#retrieveTransactionManager-org.springframework.test.context.TestContext-java.lang.String-)   

### 5.8.7. 展示所有事务相关的注解
下面展示了所有支持的事务相关的注解：  
```java
@SpringJUnitConfig
@Transactional(transactionManager = "txMgr")
@Commit
class FictitiousTransactionalTest {

    @BeforeTransaction
    void verifyInitialDatabaseState() {
        // logic to verify the initial state before a transaction is started
    }

    @BeforeEach
    void setUpTestDataWithinTransaction() {
        // set up test data within the transaction
    }

    @Test
    // overrides the class-level @Commit setting
    @Rollback
    void modifyDatabaseWithinTransaction() {
        // logic which uses the test data and modifies database state
    }

    @AfterEach
    void tearDownWithinTransaction() {
        // run "tear down" logic within the transaction
    }

    @AfterTransaction
    void verifyFinalDatabaseState() {
        // logic to verify the final state after transaction has rolled back
    }

}
```

> **当测试ORM代码时避免误报**
> 当你的测试应用代码修改Hibernate session或者JPA持久上下文状态时，确保刷新底层的工作单元。未能刷新底层的工作单元可能产生误报：你的测试通过，但是相同的代码在线上生产环境抛异常。注意，这可以适用于任何在内存中维护工作单元的ORM框架。  
> 下面的Hibernate为基础的测试实例，一个方法展示了误报，另外一个方法正确的暴露了刷新session的结果：  
> ```java
> // ...
> 
> @Autowired
> SessionFactory sessionFactory;
>
> @Transactional
> @Test // no expected exception!
> public void falsePositive() {
>   updateEntityInHibernateSession();
>   // False positive: an exception will be thrown once the Hibernate
>   // Session is finally flushed (i.e., in production code)
> }
>
> @Transactional
> @Test(expected = ...)
> public void updateWithSessionFlush() {
>   updateEntityInHibernateSession();
>   // Manual flush is required to avoid false positive in test
>   sessionFactory.getCurrentSession().flush();
> }
>
> // ...
> ```
> 
> 下面的例子展示的是JPA的：  
> ```java
> // ...
>
> @PersistenceContext
> EntityManager entityManager;
>
> @Transactional
> @Test // no expected exception!
> public void falsePositive() {
>   updateEntityInJpaPersistenceContext();
>   // False positive: an exception will be thrown once the JPA
>   // EntityManager is finally flushed (i.e., in production code)
> }
>
> @Transactional
> @Test(expected = ...)
> public void updateWithEntityManagerFlush() {
>   updateEntityInJpaPersistenceContext();
>   // Manual flush is required to avoid false positive in test
>   entityManager.flush();
> }
>
> // ...
> ```  

## 5.9. 执行SQL脚本
在对一个关系数据库写集成测试的时候，经常需要运行SQL脚本去修改数据库的schema或者插入测试数据到表中。`spring-jdbc`模块提供了初始化集成或者已存在数据库的支持，通过在`ApplicationContext`加载时执行SQL脚本。  

下面的章节是如何以编码的形式和申明的形式运行SQL脚本  

### 5.9.1. 编码形式执行SQL脚本  
Spring提供了下面的选项，以在集成测试方法中编码的形式执行SQL脚本。  
* org.springframework.jdbc.datasource.init.ScriptUtils  
* org.springframework.jdbc.datasource.init.ResourceDatabasePopulator  
* org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests  
* org.springframework.test.context.testng.AbstractTransactionalTestNGSpringContextTests    

`ScriptUtils`提供了一个有关SQL脚本的静态实用方法集合，并且他主要是为框架内部使用的。但是，如果你需要完全的控制SQL脚本的解析和运行，`ScriptUtils`可能比之后提到的工具更符合你的需求。详情参考他的[javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/datasource/init/ScriptUtils.html)  

`ResourceDatabasePopulator`提供了一个对象基础的API通过定义在外部的SQL脚本，手动编码执行填充，初始化，或者清除数据库。`ResourceDatabasePopulator`提供许多参数，包括：配置字符编码，语句分隔符，注释分隔符，和异常处理。每个配置参数都有一个合理的默认值。详情参考[javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/jdbc/datasource/init/ResourceDatabasePopulator.html) 。要运行`ResourceDatabasePopulator`配置的脚本，针对`java.sql.Connection`你可以调用`populate(Connection)`方法，针对`javax.sql.DataSource`你可以调用`execute(DataSource)`方法。  
下面的例子指定了一个有关测试schema和测试数据的SQL叫阿苯，设置了语句分隔符为`@@`，并且针对`DataSource`运行脚本。  
```java
@Test
void databaseTest() {
    ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
    populator.addScripts(
            new ClassPathResource("test-schema.sql"),
            new ClassPathResource("test-data.sql"));
    populator.setSeparator("@@");
    populator.execute(this.dataSource);
    // run code that uses the test schema and data
}
```

注意`ResourceDatabasePopulator`内部委托了`ScriptUtils`去解析和运行SQL脚本。类似的是，在`AbstractTransactionalJUnit4SpringContextTests`和`AbstractTransactionalTestNGSpringContextTests`中的`executeSqlScript(..)`方法，内部使用的是`ResourceDatabasePopulator`去运行SQL脚本。  

### 5.9.2. 通过注解`@Sql`执行脚本
除了前面提到过的通过编程的方式实现脚本执行，Spring TestContext框架还支持通过注解执行脚本，通过注解你可以在测试方法之前或者之后执行脚本。`@Sql`可以修饰到类或者方法上，可以配置独立的sql脚本或者sql脚本的资源路径，他的支持由`SqlScriptsTestExecutionListener`提供，这个listener是默认启用的。  

> 方法级别的`@Sql`申明会默认覆盖类级别的声明。从Spring Framework 5.2开始，是否覆盖可以通过`@SqlMergeMode`来配置，他可以在类级别或者方法级别配置，详情参考之前提到的`@SqlMergeMode`  

### 5.9.3. 路径资源语法
每个path都会被翻译为Spring的`Resource`。一个相对路径（比如，`"schema.sql"`）会被当做classpath资源，他会跟测试类所在的包相关联。路径以斜杠开头会被当做绝对路径（比如`"/org/example/schema.sql"`）。一个路径引用了一个URL（比如，一个path以`classpath:`，`file:`，`http:`开头）会按照指定的资源协议来加载。  

下面的例子展示了在一个以JUnit Jupiter为基础的测试类中，类和方法都被`@Sql`修饰的例子：  
```java
@SpringJUnitConfig
@Sql("/test-schema.sql")
class DatabaseTests {

    @Test
    void emptySchemaTest() {
        // run code that uses the test schema without any test data
    }

    @Test
    @Sql({"/test-schema.sql", "/test-user-data.sql"})
    void userTest() {
        // run code that uses the test schema and test data
    }
}
```

### 5.9.4. 默认脚本检测
如果`@Sql`注解没有声明任何脚本或者资源位置，那么会去检测默认的脚本位置，具体默认位置取决于注解申明位置，在类和方法上略有区别。如果没有在默认位置找到对应的sql脚本，会抛出`IllegalStateException`异常。  

* 类级别的申明：如果注解的测试类是`com.example.MyTest`，那么对应的默认脚本就是`classpath:com/example/MyTest.sql`。  
* 方法级别的申明：如果注解的方法叫做`testMethod()`并且它是定义在`com.example.MyTest`类中，那么对应的默认脚本是`classpath:com/example/MyTest.testMethod.sql`。  

### 5.9.5. 申明多个`@Sql`集
如果你需要对一个测试类或者测试方法配置多个SQL脚本集合，他们可能有不同的语法配置，不同的异常处理规则，或者不同的执行阶段，你可以申明多个`@Sql`实例。如果是Java 8 ，那么你可以重复使用`@Sql`注解。否则，你需要使用`@SqlGroup`注解去包含多个`@Sql`实例。  

下面的例子是Java 8的重复注解申明： 
```java
@Test
@Sql(scripts = "/test-schema.sql", config = @SqlConfig(commentPrefix = "`"))
@Sql("/test-user-data.sql")
void userTest() {
    // run code that uses the test schema and test data
}
```
在上面的例子中，`test-schema.sql`脚本使用了一个不同的语法：单行注释。  

下面的例子跟之前的例子相同，只不过是`@Sql`被`@SqlGroup`包装了一下。上面的例子在Java8的背景下，`@SqlGroup`是可选的，但是为了兼容性，比如需要兼容`Kotlin`，那么你只能选择`@SqlGroup`。  
```java
@Test
@SqlGroup({
    @Sql(scripts = "/test-schema.sql", config = @SqlConfig(commentPrefix = "`")),
    @Sql("/test-user-data.sql")
)}
void userTest() {
    // run code that uses the test schema and test data
}
```

### 5.9.6. 脚本执行阶段
默认情况下`@Sql`的脚本都是在测试方法之前执行的，如果你需要在测试方法之后执行（比如，清楚数据库状态），那么`@Sql`的属性`executionPhase`可以帮到你。  
```java
@Test
@Sql(
    scripts = "create-test-data.sql",
    config = @SqlConfig(transactionMode = ISOLATED)
)
@Sql(
    scripts = "delete-test-data.sql",
    config = @SqlConfig(transactionMode = ISOLATED),
    executionPhase = AFTER_TEST_METHOD
)
void userTest() {
    // run code that needs the test data to be committed
    // to the database outside of the test's transaction
}
```
注意`ISOLATED`和`AFTER_TEST_METHOD`是分别从`Sql.TransactionMode`和`Sql.ExecutionPhase`静态导入的。  

### 5.9.7. 通过`@SqlConfig`进行脚本配置
你可以配置脚本解析或者异常处理通过使用`@SqlConfig`注解。当作为一个类级别的注解申明时，`@SqlConfig`服务于整个测试类的层次结构，对其中的所有SQL脚本生效。当通过`config`属性直接申明到`@Sql`注解里的时候，`@SqlConfig`作为一个本地配置服务，只对`@Sql`注解范围内的SQL脚本生效。每个`@SqlConfig`的属性都有一个隐性的默认值。因为Java语言规范中定义的注解属性规则，注解属性是不能分配`null`值的。因此，为了支持覆盖继承的全局属性，`@SqlConfig`属性有一个显性的默认值为 ""(字符串)，{}(数组)，或者`DEFAULT`(枚举)。这种方法允许本地的`@SqlConfig`提供除了""，{}，或者`DEFAULT`以外的值来选择性的覆盖来自全局的每个属性。只要本地`@SqlConfig`没有提供一个显性的属性值（"",{},DEFAULT除外），那么对应属性仍然从全局继承。  

`@Sql`和`@SqlConfig`提供的配置选项跟`ScriptUtils`和`ResourceDatabasePopulator`提供的相等，但是是`<jdbc:initialize-database/>`提供的XML命名空间元素的超集。详情参考[@Sql](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/jdbc/Sql.html) 和[@SqlConfig](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/jdbc/SqlConfig.html)  

### 5.9.8. `@Sql`的事务管理
默认情况下，`SqlScriptsTestExecutionListener`会推断`@Sql`配置的脚本期望的事务语义。具体来说，SQL脚本没有运行在一个事务中，但在一个Spring管理的事务中（举个例子，一个由`TransactionalTestExecutionListener`管理的事务，当测试被`@Transactional`注解修饰时），或者在一个隔离的事务当中，取决于`@SqlConfig`属性`transactionMode`的取值和测试`ApplicationContext`中是否有`PlatformTransactionManager`存在。就算最低的要求，也需要一个`javax.sql.DataSource`在测试`ApplicationContext`中存在。  

如果`SqlScriptsTestExecutionListener`使用的算法通过检测`DataSource`和`PlatformTransactionManager`来推断的事务语义不符合你的需求，你可以指定显式名称通过设置`@SqlConfig`的属性`dataSource`和`transactionManager`。此外，你可以空值事务的传播方式通过设置`@SqlConfig`的`transactionMode`属性（比如，是否脚本应该运行在一个隔离的事务中）。详情参考[@SqlConfig](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/jdbc/SqlConfig.html) 和 [SqlScriptsTestExecutionListener](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/jdbc/SqlScriptsTestExecutionListener.html)  
```java
@SpringJUnitConfig(TestDatabaseConfig.class)
@Transactional
class TransactionalSqlScriptsTests {

    final JdbcTemplate jdbcTemplate;

    @Autowired
    TransactionalSqlScriptsTests(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    @Test
    @Sql("/test-data.sql")
    void usersTest() {
        // verify state in test database:
        assertNumUsers(2);
        // run code that uses the test data...
    }

    int countRowsInTable(String tableName) {
        return JdbcTestUtils.countRowsInTable(this.jdbcTemplate, tableName);
    }

    void assertNumUsers(int expected) {
        assertEquals(expected, countRowsInTable("user"),
            "Number of rows in the [user] table.");
    }
}
```
注意这里不需要在执行完`userTest()`方法后清理数据库，因为所有对数据库的修改（不管是测试方法中的，还是`/test-data.sql`脚本中的）都会由`TransactionalTestExecutionListener`自动回滚。  

### 5.9.9. `@SqlMergeMode`合并或者覆盖配置
从Spring Framework 5.2开始，合并方法级别的和类级别的`@Sql`申明成为可能。比如说，这能让你为每个测试类提供一次数据库schema配置或者提供一些常见的测试数据，然后在每个测试方法提供指定的测试数据。要开启`@Sql`合并，在你的测试类或者方法上修饰`@SqlMergeMode(MERGE)`。要为指定的方法或者子类关闭合，你可以设置模式为`@SqlMergeMode(OVERRIDE)`。  

## 5.10. 并发测试执行
Spring Framework 5.0引入了在单个JVM中并发执行测试的基础支持，当然是使用Spring TestContext框架前提下。一般来说，这意味着大多数测试类或者测试方法都可以在不修改任何测试代码或者配置的前提下并发的执行。  

> 怎样设置并发测试执行，详情可以参考你使用的测试框架，构建工具，或者IDE。  

记住在你的测试套件中引入并发可能会导致一些意想不到的副作用，奇怪的运行时行为，和间歇的测试失败或者产生随机性。因此Spring团队对于何时不适于使用并发测试有以下总结：  
* 使用Spring框架的`@DirtiesContext`。  
* 使用Spring Boot的`@MockBean`或者`@SpyBean`。
* 使用JUnit 4的`@FixMethodOrder`或者任何是设计来确保测试方法按照指定顺序执行的框架特征。注意，当整个测试类是并发运行的时候，并不适用。
* 改变共享服务或者系统的状态（比如数据库，消息代理，文件系统等等）。这适用于集成或者外部系统。  

> 如果并发测试执行失败过后，当前测试的`ApplicationContext`不再可用，这通常意味着`ApplicationContext`在另一个线程中被从`ContextCache`中移除了。  
> 
> 这可能是因为`@DirtiesContext`或者是`ContextCache`自动清除的。如果`@DirtiesContext`是罪魁祸首，你要么避免使用`@DirtiesContext`，要么避免使用并发测试。如果是由于`ContextCache`已经超过最大容量，你可以增加缓存数量的最大值。  

> 在Spring TestContext框架中测试要并发执行，只有底层`TestContext`实现提供了一个 `copy constructor`时才有效(参考[javadoc](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/context/TestContext.html) )。但是，如果使用第三方提供的自定义`TestContext`实现，你需要验证它是否适配并发测试的执行。  


## 5.11. TestContext 框架支持类
这个章节描述了Spring TestContext框架支持的各种类。  

### 5.11.1. Spring JUnit 4 Runner
TestContext框架提供了完整的JUnit 4集成，通过一个自定义的runner（在JUnit4.12或者更高版本支持）。通过修饰测试`@RunWith(SpringJUnit4ClassRunner.class)`或者更短的变体`@RunWith(SpringRunner.class)`，开发者可以实现JUnit 4为基础的单元和集成测试并且同事获得TestContext框架带来的好处，比如加载ApplicationContext，测试示例的依赖注入，测试方法的事务管理等等。如果你想使用其他的runner（比如JUnit 4的`Parameterized`runner）或者第三方的runner（比如`MockitoJUnitRunner`），更多参考[ Spring’s support for JUnit rules](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit4-rules)  

下面的代码展示了配置一个测试类运行自定义Spring`Runner`的最低需求：
```java
@RunWith(SpringRunner.class)
@TestExecutionListeners({})
public class SimpleTest {

    @Test
    public void testMethod() {
        // test logic...
    }
}
```
上面的例子中`@TestExecutionListeners`被配置为一个空的list，这样会关闭所有默认的listener，否则需要通过`@ContextConfiguration`配置一个`ApplicationContext`。  

### 5.11.2. Spring JUnit 规则  
`org.springframework.test.context.junit4.rules`包提供了以下JUnit 4规则（在JUnit4.12或者更高版本支持）：  
* SpringClassRule
* SpringMethodRule  

`SpringClassRule`是一个JUnit`TestRule`，他支持TestContext框架类级别的特征，但是`SpringMethodRule`是一个JUnit`MethodRule`，他支持TestContext框架实例级别或者方法级别的特征。  

相对于`SpringRunner`，Spring规则基础的Junit支持具有独立于任何`org.junit.runner.Runner`实现的有点，因此，可以和已存在的runner（比如JUnit4的`Parameterized`）或者第三方的runner结合使用（`MockitoJUnitRunner`）。  

为了支持TestContext框架的完整功能，你必须结合一个`SpringClassRule`和一个`SpringMethodRule`。下面的例子展示了在继承测试中如何正确的申明这些规则：  
```java

// Optionally specify a non-Spring Runner via @RunWith(...)
@ContextConfiguration
public class IntegrationTest {

    @ClassRule
    public static final SpringClassRule springClassRule = new SpringClassRule();

    @Rule
    public final SpringMethodRule springMethodRule = new SpringMethodRule();

    @Test
    public void testMethod() {
        // test logic...
    }
}
```

### 5.11.3. JUnit 4 支持类
`org.springframework.test.context.junit4`为JUnit4(在JUnit4.12或者更高版本支持)为基础的测试案例提供了以下支持类：  
* AbstractJUnit4SpringContextTests  
* AbstractTransactionalJUnit4SpringContextTests  

`AbstractJUnit4SpringContextTests`是一个抽象测试基类，他集成了在JUnit 4环境的TestContext框架带有显式的`ApplicationContext`测试支持。当你extend`AbstractJUnit4SpringContextTests`，你可以访问一个`protected``applicationContext`实例参数，用它来执行显式的bean查找或者测试整个上下文的状态。  

`AbstractTransactionalJUnit4SpringContextTests`是对`AbstractJUnit4SpringContextTests`的一个抽象事物的扩展，它新增了一些有关JDBC的便捷访问。这个类需要`ApplicationContext`中定义了一个`javax.sql.DataSource`bean和一个`PlatformTransactionManager`bean。当你extend`AbstractTransactionalJUnit4SpringContextTests`，你可以访问一个`protected``jdbcTemplate`实例参数，你可以用它来跑SQL语句。你可以在数据库相关代码运行前后确定数据库的状态，Spring会确保应用代码的query在相同的事务中。当配合ORM工具使用时，需要确保避免`false positives`，之前提到过。`AbstractTransactionalJUnit4SpringContextTests`也提供了快捷方法，他们都是委托`JdbcTestUtils`的方法完成的通过前面提到的`jdbcTemplate`。此外，`AbstractTransactionalJUnit4SpringContextTests`提供了一个`executeSqlScript(..)`方法可以运行SQL脚本。  

> 这些类方便了扩展。但是如果你不像你的测试类跟Spring指定的类结构绑定，那么你可以通过`@RunWith(SpringRunner.class)`或者 Spring’s JUnit rules。  

### 5.11.4. SpringExtension for JUnit Jupiter
TestContext框架为JUnit5引入的JUnit Jupiter测试框架提供了完整的集成。通过注解测试类`@ExtendWith(SpringExtension.class)`，你可以实现标准的JUnit Jupiter为基础的单元或者集成测试同事也可以从TestContext框架中受益。  

此外，多亏了JUnit Jupiter丰富的扩展，Spring提供了以下特征，它比Spring对JUnit4和TestNG特征的支持要更多更完善：
* 测试构造方法，测试方法，和测试声明周期回调方法的依赖注入。详情参考[Dependency Injection with SpringExtension](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-di)  
* 强力支持基于SpEL表达式的[条件化测试执行](https://junit.org/junit5/docs/current/user-guide/#extensions-conditions) ，环境变量，系统属性等等。参考`@EnabledIf`和`@DisabledIf`在[ Spring JUnit Jupiter Testing Annotations](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-junit-jupiter) 中  
* 自定义复合注解由Spring和JUnit Jupiter的注解组成。参考`@TransactionalDevTestConfig`和`@TransactionalIntegrationTest`的例子在[ Meta-Annotation Support for Testing](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-meta)  

下面的例子是一个使用实例：  
```java
// Instructs JUnit Jupiter to extend the test with Spring support.
@ExtendWith(SpringExtension.class)
// Instructs Spring to load an ApplicationContext from TestConfig.class
@ContextConfiguration(classes = TestConfig.class)
class SimpleTests {

    @Test
    void testMethod() {
        // test logic...
    }
}
```
因为你也可以使用JUnit 5的注解作为元注解，所以Spring提供了`@SpringJUnitConfig`和`@SpringJUnitWebConfig`他们组合了必要的注解。  

下面是一个`@SpringJUnitConfig`的例子：  
```java
// Instructs Spring to register the SpringExtension with JUnit
// Jupiter and load an ApplicationContext from TestConfig.class
@SpringJUnitConfig(TestConfig.class)
class SimpleTests {

    @Test
    void testMethod() {
        // test logic...
    }
}
```

同样的，下面是一个`@SpringJUnitWebConfig`例子，为JUnit Jupiter创建了一个`WebApplicationContext`：  
```java
// Instructs Spring to register the SpringExtension with JUnit
// Jupiter and load a WebApplicationContext from TestWebConfig.class
@SpringJUnitWebConfig(TestWebConfig.class)
class SimpleWebTests {

    @Test
    void testMethod() {
        // test logic...
    }
}
```
详情参考[ Spring JUnit Jupiter Testing Annotations](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-junit-jupiter)  

### 5.11.5. Dependency Injection with `SpringExtension`
`SpringExtension`实现了来自JUnit Jupiter的`ParameterResoler`扩展API，它让Spring为测试构造函数，测试方法，和测试生命周期回调函数提供了依赖注入。  

具体来说，`SpringExtension`你可以注入来自测试的`ApplicationContext`中的依赖到测试构造函数和被`@BeforeAll,` `@AfterAll`, `@BeforeEach`, `@AfterEach`, `@Test`, `@RepeatedTest`, `@ParameterizedTest`，和其他注解修饰的方法中。  

#### 构造函数注入
如果构造器中的指定参数是`ApplicationContext`类型（或者其子类型）或者是其被以下注解或者元注解修饰：@Autowired，@Qualifier，或者@Value，Spring会根据来自测试`ApplicationContext`中对应bean或者value来注入值。  

Spring可以为测试类的构造函数配置自动装配所有的参数，如果构造函数是考虑成为自动装配化的。一个构造函数是否考虑自动装配化，下面的条件有一个满足就可以（按优先顺序）。  
* 构造函数被`@Autowired`修饰。  
* `@TestConstructor`注解在测试类上存在或者他的元注解，并且`autowireMode`属性要为`ALL`。  
* 默认的测试构造函数自动装配模式改为了`ALL`。  

详情参考[@TestConstructor](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-testconstructor)  

> 如果测试类的构造函数考虑成为自动装配化的，Spring会承担构造函数所有参数的解析工作。这会导致，这样的构造函数不会有其他通过JUnit Jupiter注册的`ParameterResolver`能够解析他的参数。  

> 如果测试方法申明了`@DirtiesContext`来在方法执行前或者执行后关闭`ApplicationContext`，那么就不能将构造器注入和JUnit Jupiter的`@TestInstance(PER_CLASS)`配合使用。  
> 
> 原因是因为`@TestInstance(PER_CLASS)`让JUnit Jupiter去缓存了测试方法调用之间的测试实例。因此，测试实例将会保留即将被关闭的`ApplicationContext`中的bean引用。因为在这种场景下，测试类的构造器只会被调用一次，依赖注入不会再次执行，接下来的测试交互的都是一个关闭的`ApplicationContext`，会直接抛出异常。  
> 
> 要配合`@TestInstance(PER_CLASS)`使用`before test method`或者`after test method`模式的`@DirtiesContext`，必须要通过字段或者setter方式的依赖注入，这样就能在测试方法调用之间重新注入。  

下面的例子中，Spring注入来自`ApplicationContext`的`OrderService`bean到`OrderServiceIntegrationTests`构造方法中。  
```java
@SpringJUnitConfig(TestConfig.class)
class OrderServiceIntegrationTests {

    private final OrderService orderService;

    @Autowired
    OrderServiceIntegrationTests(OrderService orderService) {
        this.orderService = orderService;
    }

    // tests that use the injected OrderService
}
```
注意这个特征让测试依赖成为`final`，因此不能更改。  

如果`spring.test.constructor.autowire.mode`属性值是`all`(详情参考[@TestConstructor](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-testconstructor) )，我们可以忽略之前例子中构造方法上的`@Autowired`，结果如下：  
```java
@SpringJUnitConfig(TestConfig.class)
class OrderServiceIntegrationTests {

    private final OrderService orderService;

    OrderServiceIntegrationTests(OrderService orderService) {
        this.orderService = orderService;
    }

    // tests that use the injected OrderService
}
```

#### 方法注入
如果JUnit Jupiter测试方法或者测试声明周期回调方法的一个参数是`ApplicationContext`类型（或者是其子类型）或者是被一下注解或元注解修饰的：`@Autowird`，`@Qualifier`，或者`@Value`，Spring会为指定的参数注入`ApplicationContext`中对应的bean。  

下面的就是一个方法注入的实例：  
```java
@SpringJUnitConfig(TestConfig.class)
class OrderServiceIntegrationTests {

    @Test
    void deleteOrder(@Autowired OrderService orderService) {
        // use orderService from the test's ApplicationContext
    }
}
```
因为在JUnit Jupiter中对`ParameterResolver`支持的稳健性，你可以有多个依赖注入到单个方法中，不仅是来自Spring，也可以是来自JUnit Jupiter或者其他第三方的扩展。  

下面的例子展示如何同时有Spring和JUnit Jupiter的注入到同一个测试方法中：  
```java
@SpringJUnitConfig(TestConfig.class)
class OrderServiceIntegrationTests {

    @RepeatedTest(10)
    void placeOrderRepeatedly(RepetitionInfo repetitionInfo,
            @Autowired OrderService orderService) {

        // use orderService from the test's ApplicationContext
        // and repetitionInfo from JUnit Jupiter
    }
}
```
注意使用来自JUnit Jupiter的`@RepeatedTest`，可以让方法有权限访问`RepetitionInfo`。  

### 5.11.6. `@Nested`测试类配置
从Spring Framework 5.0开始，Spring TestContext框架支持在JUnit Jupiter的`@Nested`测试类上使用测试相关的注解；但是，直到Spring Framework5.3，类级别的测试配置注解才从封闭类继承而来，就像他们继承来自父类的一样。  

Spring Framework 5.3 引入了良好的内部类配置继承支持，并且将会默认启用。要改变默认的`INHERIT`模式为`OVERRIDE`模式，你可以给每个`@Nested`测试类添加一个`@NestedTestConfiguration(EnclosingConfiguration.OVERRIDE)`。一个显式`@NestedTestConfiguration`申明不仅对注解修饰的测试类有效也对其子类和集成的类有效。因此，你可以用`@NestedTestConfiguration`注解修饰顶级测试类，让后递归应用到其所有集成的测试类上。  

为了允许开发团队修改默认的模型为`OVERRIDE`——举个例子，为了兼容Spring Framework 5.0到5.2——默认的模型可以全局修改通过JVM系统属性或者一个在classpath根路径下的`spring.properties`文件。详情参考["Changing the default enclosing configuration inheritance mode"](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#integration-testing-annotations-nestedtestconfiguration)   

下面的`Hello World`例子是非常简单的，他展示了怎样申明常用的配置到顶级类上，方便它的集成类能够继承这些配置。在这个例子中，只有`TestConfig`配置类是继承的。每个集成测试类提供了它自己的激活配置文件，结果就是每个继承测试类都有一个不同的`ApplicationContext`。  
```java
@SpringJUnitConfig(TestConfig.class)
class GreetingServiceTests {

    @Nested
    @ActiveProfiles("lang_en")
    class EnglishGreetings {

        @Test
        void hello(@Autowired GreetingService service) {
            assertThat(service.greetWorld()).isEqualTo("Hello World");
        }
    }

    @Nested
    @ActiveProfiles("lang_de")
    class GermanGreetings {

        @Test
        void hello(@Autowired GreetingService service) {
            assertThat(service.greetWorld()).isEqualTo("Hallo Welt");
        }
    }
}
```

### 5.11.7. TestNG支持类
`org.springframework.test.context.testng`为TestNG为基础的测试案例提供了以下支持类：
* AbstractTestNGSpringContextTests
* AbstractTransactionalTestNGSpringContextTests

`AbstractTestNGSpringContextTests`是一个抽象测试基类，他集成了在TestNG环境的TestContext框架带有显式的`ApplicationContext`测试支持。当你extend`AbstractTestNGSpringContextTests`，你可以访问一个`protected``applicationContext`实例参数，用它来执行显式的bean查找或者测试整个上下文的状态。

`AbstractTransactionalTestNGSpringContextTests`是对`AbstractTestNGSpringContextTests`的一个抽象事物的扩展，它新增了一些有关JDBC的便捷访问。这个类需要`ApplicationContext`中定义一个`javax.sql.DataSource`bean和一个`PlatformTransactionManager`bean。当你extend`AbstractTransactionalTestNGSpringContextTests`，你可以访问一个`protected``jdbcTemplate`实例参数，你可以用它来跑SQL语句。你可以在数据库相关代码运行前后确定数据库的状态，Spring会确保应用代码的query在相同的事务中。当配合ORM工具使用时，需要确保避免`false positives`，之前提到过。`AbstractTransactionalTestNGSpringContextTests`也提供了快捷方法，他们都是委托`JdbcTestUtils`的方法完成的通过前面提到的`jdbcTemplate`。此外，`AbstractTransactionalTestNGSpringContextTests`提供了一个`executeSqlScript(..)`方法可以运行SQL脚本。  

> 这些类方便了扩展。如果你不想你的测试类和Spring指定的类结构绑定，你可以配置你自己的自定义测试类，通过使用`@ContextConfiguration`,`@TestExecutionListeners`等，并且通过`TestContextManager`手动检测你的测试类。关于如何检测你的测试类，参考`AbstractTestNGSpringContextTests`源码。  

# 6. WebTestClient
`WebTestClient`是一个设计用于测试服务应用的HTTP客户端。它包装了Spring的[WebClient](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-client) ，并且用它来执行请求，并且暴露一个验证response的测试门面。`WebTestClient`可以用来执行端对端的HTTP测试。它也可以用来测试Spring MVC和Spring WebFlux应用，而且不需要运行服务，通过模拟请求和返回对象。  

> Kotlin用户：查看[this section](https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin-webtestclient-issue) 相关的`WebTestClient`使用。  

## 6.1. 配置
要配置一个`WebTestClient`，你需要选择一个服务配置来绑定。这可以是众多模拟服务器配置中的一个或者一个实时线上服务器的连接。  

### 绑定到Controller
这个配置允许你测试指定的controller通过虚拟的request和response对象，并且不需要运行服务。  

对于WebFlux应用，使用下面的代码加载基础框架等于[WebFlux Java config](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-config) ，注册给定的controller，然后创建一个[WebHandler chain](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-web-handler-api) 去处理request：  
```java
WebTestClient client =
        WebTestClient.bindToController(new TestController()).build();
```

对于Spring MVC，使用下面的代码委托`StandaloneMockMvcBuilder`去加载与[WebMvc Java config](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-config)  等效的基础架构，注册给定的controller，并且创建一个[MockMvc](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#spring-mvc-test-framework) 实例去处理request：  
```java
WebTestClient client =
        MockMvcWebTestClient.bindToController(new TestController()).build();
```

### 绑定到 ApplicationContext
这个配置允许你通过Spring MVC或者Spring WebFlux基础框架和controller申明来加载Spring配置，并且通过模拟的request和response对象处理去处理请求，而无需运行服务。  

对于WebFlux，使用以下内容传递Spring`ApplicationContext`到[WebHttpHandlerBuilder](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/web/server/adapter/WebHttpHandlerBuilder.html#applicationContext-org.springframework.context.ApplicationContext-) 中去创建[WebHandler chain](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-web-handler-api) 以处理请求：
```java
@SpringJUnitConfig(WebConfig.class) 
class MyTests {

    WebTestClient client;

    @BeforeEach
    void setUp(ApplicationContext context) {  
        client = WebTestClient.bindToApplicationContext(context).build(); 
    }
}
```

对于Spring MVC，使用以下内容传递Spring`ApplicationContext`到[MockMvcBuilders.webAppContextSetup](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/web/servlet/setup/MockMvcBuilders.html#webAppContextSetup-org.springframework.web.context.WebApplicationContext-) 去创建一个[MockMvc](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#spring-mvc-test-framework) 实例以处理请求：  
```java
@ExtendWith(SpringExtension.class)
@WebAppConfiguration("classpath:META-INF/web-resources") 
@ContextHierarchy({
    @ContextConfiguration(classes = RootConfig.class),
    @ContextConfiguration(classes = WebConfig.class)
})
class MyTests {

    @Autowired
    WebApplicationContext wac; 

    WebTestClient client;

    @BeforeEach
    void setUp() {
        client = MockMvcWebTestClient.bindToApplicationContext(this.wac).build(); 
    }
}
```

### 绑定到 Router Function
这个配置允许你在不启动服务的情况下通过模拟request和response对象测试[functional endpoints](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-fn)  

对于WebFlux，使用下面内容委托给`RouterFunctions.toWebHandler`去创建一个服务配置以处理请求：   
```java
RouterFunction<?> route = ...
client = WebTestClient.bindToRouterFunction(route).build();
```

对于Spring MVC，目前还没有测试[ WebMvc functional endpoints](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#webmvc-fn) 的选项。  

### 绑定到服务器
这个配置连接到一个运行的服务上以进行完整的，端对端的HTTP测试：  
```java
client = WebTestClient.bindToServer().baseUrl("http://localhost:8080").build();
```

### 客户端配置
除了之前梯级的服务配置以外，你还可以配置客户端选项，包括 base URL，默认 headers，客户端过滤器等等。这些选项在`bindToServcer()`之后都是很容易获得的。对于其他配置选项，你可以使用`configureClient()`将服务转为客户端配置：  
```java
client = WebTestClient.bindToController(new TestController())
        .configureClient()
        .baseUrl("/test")
        .build();
```

## 6.2. 写测试
直到通过`exchange()`执行请求为止，`WebTestClient`提供和[WebClient](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-client) 相同的API。参考[WebClient](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html#webflux-client-body) 文档以查找如何准备一个有任何内容的请求，包括 form data， multipart data，等等。  

在调用`exchange()`之后，`WebTestClient`从`WebClient`偏离，转变工作流的方向去验证response。  

使用下面内容去断言response的状态和header：  
```java
client.get().uri("/persons/1")
            .accept(MediaType.APPLICATION_JSON)
            .exchange()
            .expectStatus().isOk()
            .expectHeader().contentType(MediaType.APPLICATION_JSON)
```
然后你可以通过下面任何一种方法去解码reponse的body：  
* expectBody(Class<T>)：解码为单个对象。  
* expectBodyList(Class<T>)：解码并收集对象到List<T>。  
* expectBody()：解码到[JSON Content](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#webtestclient-json) 或者一个空的body `byte[]`  

然后在高等级的结果对象上执行断言：  
```java
client.get().uri("/persons")
        .exchange()
        .expectStatus().isOk()
        .expectBodyList(Person.class).hasSize(3).contains(person);
```

如果内置的断言效率太低，你还可以用其他的断言代替：  
```java
import org.springframework.test.web.reactive.server.expectBody

client.get().uri("/persons/1")
        .exchange()
        .expectStatus().isOk()
        .expectBody(Person.class)
        .consumeWith(result -> {
            // custom assertions (e.g. AssertJ)...
        });
```

或者你可以退出工作流，并获取一个`EntityExchangeResult`：  
```java
EntityExchangeResult<Person> result = client.get().uri("/persons/1")
        .exchange()
        .expectStatus().isOk()
        .expectBody(Person.class)
        .returnResult();
```

> 当你需要解码的目标类型是一个泛型时，请寻找接受[ParameterizedTypeReference](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/core/ParameterizedTypeReference.html) 而不是`Class<T>`的重载方法  

### No Content
如果不期待response会返回任何内容，你可以这样断言：  
```java
client.post().uri("/persons")
        .body(personMono, Person.class)
        .exchange()
        .expectStatus().isCreated()
        .expectBody().isEmpty();
```

如果需要忽略response内容，下面就是是释放内容并不需要任何断言：  
```java
client.get().uri("/persons/123")
        .exchange()
        .expectStatus().isNotFound()
        .expectBody(Void.class);
```

### JSON Content
你可以使用`expectBody()`，他没有目标类型，他断言的目标是为加工的内容而不是高等级的对象。  

用[JSONAssert](https://jsonassert.skyscreamer.org/) 验证完整的JSON内容：  
```java
client.get().uri("/persons/1")
        .exchange()
        .expectStatus().isOk()
        .expectBody()
        .json("{\"name\":\"Jane\"}")
```

用[JSONPath](https://github.com/json-path/JsonPath) 验证JSON内容：  
```java
client.get().uri("/persons")
        .exchange()
        .expectStatus().isOk()
        .expectBody()
        .jsonPath("$[0].name").isEqualTo("Jane")
        .jsonPath("$[1].name").isEqualTo("Jason");
```

### Streaming Responses
要测试一个可能无穷尽的流，比如说`"text/event-stream"`或者`"application/x-ndjson"`，通过验证response状态和header开始，然后获取一个`FluxExchangeResult`：  
```java
FluxExchangeResult<MyEvent> result = client.get().uri("/events")
        .accept(TEXT_EVENT_STREAM)
        .exchange()
        .expectStatus().isOk()
        .returnResult(MyEvent.class);
```

现在你已经准备好通过来自`reactor-test`的`StepVerifier`去消耗response流了：  
```java
Flux<Event> eventFlux = result.getResponseBody();

StepVerifier.create(eventFlux)
        .expectNext(person)
        .expectNextCount(4)
        .consumeNextWith(p -> ...)
        .thenCancel()
        .verify(); 
```

### MockMvc断言
`WebTestClient`是一个HTTP客户端，因此他只能验证客户端的response，包括状态，head,和body。  

当用一个MockMVC服务配置测试一个Spring MVC应用时，你有一个额外的选择可以在服务response上执行更多的断言。通过在断言body后获取一个`ExchangeResult`来实现：  
```java
// For a response with a body
EntityExchangeResult<Person> result = client.get().uri("/persons/1")
        .exchange()
        .expectStatus().isOk()
        .expectBody(Person.class)
        .returnResult();

// For a response without a body
EntityExchangeResult<Void> result = client.get().uri("/path")
        .exchange()
        .expectBody().isEmpty();
```
然后切换到MockMvc服务response断言：  
```java
MockMvcWebTestClient.resultActionsFor(result)
        .andExpect(model().attribute("integer", 3))
        .andExpect(model().attribute("string", "a string value"));
```

# 7. `MockMvc`
Spring MVC Test 框架，也叫作MockMvc，为测试Spring MVC应用提供了支持。他执行了完整的Spring MVC请求处理，但是是通过模拟的request和response对象从而代替一个运行的服务。  

MockMvc可以用在它自己身上去支持请求和response验证。它也可以通过`WebTestClient`来使用，他是通过插入到`WebTestClient`中作为处理请求的服务。`WebTestClient`带来的好处是可以不用再看着未加工的数据，可以将response body解码到高等级对象中，并且还可以切换到完整的端对端的HTTP测试，并且使用的是相同的测试API。  

## 7.1. 大纲  
你可以在普通的单元测试中使用controller，通过初始化一个controller，注入他的依赖，并调用他的方法。 但是，这样的测试不能验证 request mappings, data binding, message conversion, type conversion, validation, 并且不能涉及任何支持`@InitBinder`，`@ModelAttribute`，或者`@ExceptionHandler`的方法。  

Spring MVC Test框架，也叫`MockMVC`，旨在不需要运行服务的情况下提供更完整的Spring MVC controller测试支持。这是通过调用`DispacherServlet`并且传递了一个来自`spring-test`模组的[模拟的Servlet API实现](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#mock-objects-servlet) ，它复制了完整的Spring MVC请求处理逻辑，并且不需要启动服务。  

MockMvc 是一个服务端的测试框架，他通过使用轻量和目标性的测试可以让你验证Spring MVC应用的大多数功能。  

### 静态导入
当使用MockMvc直接执行请求时，你会需要静态导入：  
* MockMvcBuilders.*  
* MockMvcRequestBuilders.*
* MockMvcResultMatchers.*  
* MockMvcResultHandlers.*  

一个简单的方法去记住这些类，可以通过ide搜索`MockMvc*`。  

当通过`WebTestClient`使用MockMvc时，你不需要静态导入。`WebTestClient`提供了流畅的API并且不需要静态导入。  

### 配置选择
MockMvc可以有两个方法可以配置。一个是直接指出你想要测试的controller，并且以编程的方式配置Spring MVC基础结构。另外一个是指出带有Spring MVC和controller基础结构的Spring配置。  

配置MockMvc去测试一个指定的controller：  
```java
class MyWebTests {

    MockMvc mockMvc;

    @BeforeEach
    void setup() {
        this.mockMvc = MockMvcBuilders.standaloneSetup(new AccountController()).build();
    }

    // ...

}
```
当通过`WebTestClient`使用时，也可以使用这个配置，它会委托给跟上面相同的构造器。  

通过Spring配置来初始化MockMvc：  
```java
@SpringJUnitWebConfig(locations = "my-servlet-context.xml")
class MyWebTests {

    MockMvc mockMvc;

    @BeforeEach
    void setup(WebApplicationContext wac) {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(this.wac).build();
    }

    // ...

}
```
或者在通过`WebTestClient`使用时仍然可以使用上面的配置，`WebTestClient`委托给跟上面相同的builder来完成。  

你应该使用哪个配置选项？  

`webAppContextSetup`加载你实际的Spring MVC配置，生成一个更加完整的集成测试。因为TestContext框架加载了Spring配置，它帮助测试更快的运行，即使你在你的测试套件中引入了更多的测试。此外，你可以通过Spring配置注入模拟service到controller中以在web层测试上保持专注。下面的例子通过Mockito申明了一个模拟的service：  
```xml
<bean id="accountService" class="org.mockito.Mockito" factory-method="mock">
    <constructor-arg value="org.example.AccountService"/>
</bean>
```
然后你可以将这个模拟service注入到测试中，配置并验证你的期望结果：  
```java
@SpringJUnitWebConfig(locations = "test-servlet-context.xml")
class AccountTests {

    @Autowired
    AccountService accountService;

    MockMvc mockMvc;

    @BeforeEach
    void setup(WebApplicationContext wac) {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(wac).build();
    }

    // ...

}
```

另一方面，`standaloneSetup`更接近于单元测试。他一次测试一个controller。你可以通过模拟依赖手动注入controller，并且不会涉及加载Spring配置。这样的测试更专注于样式，使得查看被测试的controller，或是任何指定的Spring MVC配置是否是运行的必要条件等等操作更加容易。用`standaloneSetup`写临时的测试去验证指定的操作或者debug一个问题都非常方便。  

像大多数的“集成测试和单元测试对比”的讨论，都没有完全正确或者错误的答案。但是，使用`standaloneSetup`确实会需要一些额外的`webAppContextSetup`测试，这是为了验证你的Spring MVC配置。当然，你也可以把所有的测试都用`webAppContextSetup`来写，可以让你的测试都是基于实际的Spring MVC配置进行。  

### 配置特征
不管使用哪种MockMvc构建方法，所有的`MockMvcBuilder`实现都提供了一些常用并且非常有用的特征。比如，你可以为所有的request申明一个`Accept`header并且假定所有response的状态都是200并且还带一个`Content-type`header：  
```java
// static import of MockMvcBuilders.standaloneSetup

MockMvc mockMvc = standaloneSetup(new MusicController())
    .defaultRequest(get("/").accept(MediaType.APPLICATION_JSON))
    .alwaysExpect(status().isOk())
    .alwaysExpect(content().contentType("application/json;charset=UTF-8"))
    .build();
```
此外，第三方框架（和应用）可以预包装配置指令，就像`MockMvcConfigurer`中的一样。Spring框架也有一个继承的实现，可以帮助你在request之间保存和复用HTTP session：  
```java
// static import of SharedHttpSessionConfigurer.sharedHttpSession

MockMvc mockMvc = MockMvcBuilders.standaloneSetup(new TestController())
        .apply(sharedHttpSession())
        .build();

// Use mockMvc to perform requests...
```
详情参考[ConfigurableMockMvcBuilder](https://docs.spring.io/spring-framework/docs/5.3.2/javadoc-api/org/springframework/test/web/servlet/setup/ConfigurableMockMvcBuilder.html) 列出了所有MockMvc builder的特征。  

### 执行请求
这个章节讲述MockMvc自身怎样执行请求和验证response。如果是通过`WebTestClient`使用，可以参考之前的章节。  

使用任何HTTP方法执行请求：  
```java
mockMvc.perform(post("/hotels/{id}", 42).accept(MediaType.APPLICATION_JSON));
```
你也可以执行文件上传请求，它内部使用的是`MockMultipartHttpServletRequest`，没有实际解析一个multipart request：  
```java
mockMvc.perform(multipart("/doc").file("a1", "ABC".getBytes("UTF-8")));
```

你可以在URI模板样式中指定请求参数：  
```java
mockMvc.perform(get("/hotels?thing={thing}", "somewhere"));
```

你可以通过下面的方式呈现参数：  
```java
mockMvc.perform(get("/hotels").param("thing", "somewhere"));
```

如果应用代码依赖Servlet请求参数，并且没有清晰的检查请求string(大多数情况都是这样)，那么你选择那个方法都没有关系。但是，请记住，URI模板提供的请求参数是已经解码的，但是通过`param(...)`提供的请求参数 `are expected to already be decoded`。  

在大多数情况下，更偏向于将context path和Servlet path从请求URI中分离。如果你必须测试一个完整的请求URI，那么请确保`contextPath`和`servletPath`的准确性：  
```java
mockMvc.perform(get("/app/main/hotels/{id}").contextPath("/app").servletPath("/main"))
```
在上面的例子中，如果每个请求都附带`contextPath`和`servletPath`是十分笨重的。相对的，你可以提前设置好默认属性：  
```java
class MyWebTests {

    MockMvc mockMvc;

    @BeforeEach
    void setup() {
        mockMvc = standaloneSetup(new AccountController())
            .defaultRequest(get("/")
            .contextPath("/app").servletPath("/main")
            .accept(MediaType.APPLICATION_JSON)).build();
    }
}
```
上面的属性通过`MockMvc`影响每一个请求执行。如果给定的请求指定了同样的属性，那么它会覆盖默认值。这就是为什么默认请求中的HTTP方法和URI无关紧要的原因，因为他们都必须在每个请求中指定。  

### 定义预期结果
你可以通过一个或者多个`.andExpect(..)`定义预期结果：  
```java
mockMvc.perform(get("/accounts/1")).andExpect(status().isOk());
```
`MockMvcResultMatchers.*`提供了很多预期结果，他们中的一些可以嵌套为更详情的结果。  

预期结果可以划分为两个大致的种类。一个是验证response的属性（比如，response status,header,和内容）。这是要断言的最重要的结果内容。  

第二个断言的分类超出了response的范围。这些断言让你检查Spring MVC指定的切面，比如哪个controller方法处理了这个请求，是否有异常出现并被处理，model的具体内容，那个view被选中，什么flash属性被添加等等。他们也能让你检查Servlet指定的切面，比如说request和session属性。  

下面的测试断言了绑定或者验证失败：  
```java
mockMvc.perform(post("/persons"))
    .andExpect(status().isOk())
    .andExpect(model().attributeHasErrors("person"));
```
许多时候，转存执行测试请求后的结果都是非常有用的。你可以像下边这样做，`print()`是由`MockMvcResultHandlers`静态导入的：    
```java
mockMvc.perform(post("/persons"))
.andDo(print())
.andExpect(status().isOk())
.andExpect(model().attributeHasErrors("person"));
```
只要请求进程不会产生一个不能处理的异常，`print()`方法就会打印所有可用的结果数据到`System.out`中。这里有一个`log()`方法和两个额外的`print()`方法的变体，一个接收`OutputStream`，另外一个接收`Writer`。举个例子，调用`print(System.err)`打印结果到`System.err`，当调用`print(myWriter)`打印结果到一个自定义的writer。如果你想用log的形式而不是print，那么你可以调用`log()`方法，他会将结果数据作为一条单一的`DEUBG`信息在`org.springframework.test.web.servlet.result`logging目录下。  

某些情况你可能想直接获得结果对象进行验证，你可以通过`.andReturn()`，在所有的expect方法之后调用：  
```java
MvcResult mvcResult = mockMvc.perform(post("/persons")).andExpect(status().isOk()).andReturn();
// ...
```

如果所有的测试都检测一个预期结果，那么你可以在构建`MockMvc`时就设置默认的预期结果：  
```java
standaloneSetup(new SimpleController())
    .alwaysExpect(status().isOk())
    .alwaysExpect(content().contentType("application/json;charset=UTF-8"))
    .build()
```
注意这些通用的预期结果始终都是可用的，并且不能够被覆盖，除非创建一个单独的`MockMvc`实例。  

当一个JSON response内容包含一个由[Spring HATEOAS](https://github.com/spring-projects/spring-hateoas) 创建的多媒体连接，你可以通过使用JsonPath表达式来验证结果连接：  
```java
mockMvc.perform(get("/people").accept(MediaType.APPLICATION_JSON))
    .andExpect(jsonPath("$.links[?(@.rel == 'self')].href").value("http://localhost:8080/people"));
```

当XML response内容包含一个由[Spring HATEOAS](https://github.com/spring-projects/spring-hateoas) 创建的多媒体连接，你可以通过使用XPath表达式验证结果连接。  
```java
Map<String, String> ns = Collections.singletonMap("ns", "http://www.w3.org/2005/Atom");
mockMvc.perform(get("/handle").accept(MediaType.APPLICATION_XML))
    .andExpect(xpath("/person/ns:link[@rel='self']/@href", ns).string("http://localhost:8080/people"));
```

### 异步请求
这个章节展示怎样使用MockMvc进行异步请求处理。如果通过`WebTestClient`使用MockMvc，那么是不需要特别处理的，因为默认就是异步请求。  

[Spring MVC支持Servlet 3.0 异步请求](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc-ann-async) ，是通过退出Servlet容器线程，并允许应用异步计算response，然后通过异步调度去完成对Servlet容器线程的处理。  

在Spring MVC测试中，异步请求可以通过先断言产生的异步value开始，然后手动执行异步调度，并且最终验证response。下面的例子测试的controller方法返回的`deferredResult`，`Callable`，或者交互类型比如Reactor`Mono`：  
```java
@Test
void test() throws Exception {
    MvcResult mvcResult = this.mockMvc.perform(get("/path"))
            //检测response状态是仍然未改变的
            .andExpect(status().isOk()) 
            //异步处理必须有一个started
            .andExpect(request().asyncStarted())
            //等待并断言异步结果
            .andExpect(request().asyncResult("body")) 
            .andReturn();

    //手动执行异步调度（因为没有运行的容器）
    this.mockMvc.perform(asyncDispatch(mvcResult))
            //验证最终response    
            .andExpect(status().isOk()) 
            .andExpect(content().string("body"));
}
```
### Streaming Response
在Spring MVC测试中是有没有选项去测试无容器的返回流的。但是你可以通过`WebTestClient`请求去测试流。在Spring Boot中你可以[测试一个运行的服务](https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-testing-spring-boot-applications-testing-with-running-server) 通过`WebTestClient`。另外一个优势是他有能力使用来自项目Reactor的`StepVerifier`，可以允许在流数据上申明预期结果。  

### 过滤器注册
当配置一个`MockMvc`实例时，你可以注册一个或者多个Servlet`Filter`实例：  
```java
mockMvc = standaloneSetup(new PersonController()).addFilters(new CharacterEncodingFilter()).build();
```
注册的过滤器是通过来自`spring-test`的`MockFilterChain`来调用的，并且最后一个过滤器委托给了`DispacherServlet`。  

### 更多代码实例
[MockMvc](https://github.com/spring-projects/spring-framework/tree/master/spring-test/src/test/java/org/springframework/test/web/servlet/samples) ，[WebTestClient](https://github.com/spring-projects/spring-framework/tree/master/spring-test/src/test/java/org/springframework/test/web/servlet/samples/client) 

# 8. 测试客户端应用
你可以使用客户端测试，它内部使用的是`RestTemplate`。这个逻辑是申明期待的请求和提供"stub"response，所以你可以在不运行服务的情况下检测代码。  
```java
RestTemplate restTemplate = new RestTemplate();

MockRestServiceServer mockServer = MockRestServiceServer.bindTo(restTemplate).build();
mockServer.expect(requestTo("/greeting")).andRespond(withSuccess());

// Test code that uses the above RestTemplate ...

mockServer.verify();
```
在之前的例子中，`MockRestServiceServer`（客户端REST测试的核心类）用一个自定义的`ClientHttpRequestFactory`配置了`RestTemplate`，并断言了一个预期的真实请求和返回"stub"response。在这个案例中，我们期待一个到`/greeting`的请求，并且希望返回一个200 response，并带着`text/plain`内容。我们可以根据需要定义其他的请求和stub response。当我们定义期待的request和stub response时，restTemplate可以照常在客户端代码中使用。在测试结束时，`mockServer.verify()`可以用来验证所有的期望结果是否都被满足了。  

默认情况下，请求应按照expect申明期望的顺序执行。当构建服务时你可以设置`ignoreExpectOrder`选项，在这种情况下会检测所有的expect以找到一个跟给定request匹配。这意味着请求可以以任何顺序进入：  
```java
server = MockRestServiceServer.bindTo(restTemplate).ignoreExpectOrder(true).build();
```
即使改为无序请求，每个请求也只允许运行一次。expect方法提供一个重载变体，可以接受一个`ExpectedCount`参数以指定一个数量范围（比如说，一次，多次，max,min,between,等等）。下面的例子使用了`times`：  
```java
RestTemplate restTemplate = new RestTemplate();

MockRestServiceServer mockServer = MockRestServiceServer.bindTo(restTemplate).build();
mockServer.expect(times(2), requestTo("/something")).andRespond(withSuccess());
mockServer.expect(times(3), requestTo("/somewhere")).andRespond(withSuccess());

// ...

mockServer.verify();
```
注意，当`ignoreExpectOrder`没有设置的时候（默认情况），请求会按照expect申明期望的顺序，并且这个顺序只会对第一次出现的期望请求有效。举个例子，如果`/something`期待出现两次接下来是三次`/somewhere`，这里应该有一个`/something`请求是在`/somewhere`请求之前的，但是剩下的请求可以在任何时间进入。  

对于上面的所有内容，还有另外一个实现方式，客户端的测试支持也提供了一个`ClientHttpRequestFactory`实现，你可以配置到一个`RestTemplate`中去将它绑定到`MockMvc`实例上。它允许你使用服务端的逻辑处理请求并且不需要运行一个服务：  
```java
MockMvc mockMvc = MockMvcBuilders.webAppContextSetup(this.wac).build();
this.restTemplate = new RestTemplate(new MockMvcClientHttpRequestFactory(mockMvc));

// Test code that uses the above RestTemplate ...
```

## 8.1. 静态导入
作为服务端的测试，要流畅测试客户端需要一些静态导入。只要搜索`MockRest*`即可。  

## 8.2. 更多代码实例
[Client-side test](https://github.com/spring-projects/spring-framework/tree/master/spring-test/src/test/java/org/springframework/test/web/client/samples)  