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

## 3. JDBC测试的支持
JDBC相关的工具方法在类`JdbcTestUtils`类中，他在`org.springframework.test.jdbc`包下。它简化了标准的数据库测试场景。`JdbcTestUtils`提供了以下静态的工具方法：  
* `countRowsInTable(..)`:计算指定表有多少行数据
* `countRowsInTableWhere(..)`:计算指定表有多少行数据通过提供的where条件进行限制
* `deleteFromTables(..)`:删除指定表的所有行
* `deleteFromTableWhere(..)`:删除指定表的数据行通过提供的where条件进行限制
* `dropTables(..)`:Drop指定表  

> `AbstractTransactionalJUnit4SpringContextTests`和`AbstractTransactionalTestNGSpringContextTests`代理了前面提及的`JdbcTestUtils`类的方法。  
> `spring-jdbc`模块支持配置和启动一个集成的数据库，你可以用它进行集成测试。更多细节，参考[Embedded Database Support](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc-embedded-database-support) 和 [ Testing Data Access Logic with an Embedded Database](https://docs.spring.io/spring-framework/docs/current/reference/html/data-access.html#jdbc-embedded-database-dao-testing)  

## 4. 注解
这个章节介绍你在测试Spring应用时可以用的注解。它包含如下几个主题：  
* Spring 测试注解
* 标准注解支持
* Spring JUnit 4 测试注解
* Spring JUnit Jupiter 测试注解
* 测试元注解

### 4.1. Spring 测试注解
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

#### `@BoostrapWith`
`@BootstrapWith`是一个类级别的注解，你可以使用它配置Spring TestContext框架是怎样引导启动的。具体可以使用`@BootstrapWith`去指定一个自定的`TestContextBootstrapper`。查看[bootstrapping the TestContext framework](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-bootstrapping) 以获取详细信息  

#### `@ContextConfiguration`
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

#### `@WebAppConfiguration`
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

#### `@ContextHierarchy`
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

#### `@ActiveProfiles`
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

#### `@TestPropertySource`
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

#### `@DynamicPropertySource`
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

#### `@DirtiesContext`
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

#### `@TestExecutionListeners`
它定义了用来配置`TestExecutionListener`实现的类级别元数据(`TestExecutionListener`实现是由`TestContextManager`来注册的)。一般来说都是配合`@ContextConfiguration`来使用。  

下面的例子展示了如何注册两个`TestExecutionListener`实现
```java
@ContextConfiguration
@TestExecutionListeners({CustonTestExecutionListener.class,AnotherTestExecutionListerner.class})
class CustomTestExecutionListenerTests {}
```

默认情况下，`@TestExecutionListeners`是支持从父类继承的，或者内部类从外部封闭类继承。详情参考[@Nested test class configuration](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit-jupiter-nested-test-configuration) 和[@TestExecutionListeners javadoc](https://docs.spring.io/spring-framework/docs/5.3.1/javadoc-api/org/springframework/test/context/TestExecutionListeners.html)  


#### `@Commit`
`@Commit`代表测试方法的事务会在测试方法完成后提交。你可以将`@Commit`替换为`@Rollback(false)`。`@Commit`和`@Rollback`相似，都可以声明在类或方法上。  

使用实例：
```java
@Commit
@Test
void testProcessWithoutRollback(){
}
```

#### `@Rollback`
`@Rollback`代表测试方法执行完后，是否回滚事务。为true则回滚，否则事务会提交（跟`@Commit`一样）。该注解的默认值为true，就算没有声明该注解，事务默认也会回滚。  

当申明在类上时，`@Rollback`注解将会影响类的所有测试方法，当申明在方法时，只会影响指定方法，并会覆盖类上的全局`@Rollback`或`@Commit`配置  

使用实例：
```java
@Test
@Rollback(false)
void testProcessWithoutRollback(){
}
```

#### `@BeforeTransaction`
它代表注解的`void`方法应该在事务启动之前运行，对测试方法来说，它已经被配置好了在一个事务中运行，是通过使用Spring的`@Transactional`注解来实现的。`@BeforeTransaction`方法是不需要`public`修饰的，并且可以声明在java8的接口默认方法上。  

使用实例：
```java
@BeforeTransaction
void beforeTransaction(){}
```

#### `@AfterTransaction`
它代表注解的`void`方法应该在事务结束后运行，对测试方法来说，它已经被配置好了在一个事务中运行，是通过使用Spring的`@Transactional`注解来实现的。`@AfterTransaction`方法是不需要`public`修饰的，并且可以声明在java8的接口默认方法上。
```java
@AfterTransaction
void afterTransaction(){}
```

#### `@Sql`
它是用来配置测试类或者方法需要的sql脚本的。  
```java
@Test
@Sql({"/test-schema.sql","/test-user-data.sql"})
void userTest(){}
```
详情参考[Executing SQL scripts declaratively with @Sql](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-executing-sql-declaratively)  

#### `@SqlConfig`
它用来配置如何解析和执行`@Sql`注解配置的脚本。  
```java
@Test
@Sql(
    scripts = "/test-user-data.sql",
    config = @SqlConfig(commentPrefix = "`", separator = "@@")
)
void userTest(){}
```

#### `@SqlMergeMode`
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

#### `@SqlGroup`
它是一个容器注解，内部集成了多个`@Sql`注解。你可以使用`@SqlGroup`直接声明多个集成的`@Sql`，或者你可以配合java8对重复注解的支持来使用，`@Sql`可以在同一个类和方法上声明多次，隐式的生成注解容器。
```java
@Test
@SqlGroup({
    @Sql(scripts = "/test-schema.sql",config = @SqlConfig(commentPrefix = "`")),
    @Sql("/test-user-data.sql")
})
void userTest(){}
```

### 4.2. 标准注解支持
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

### 4.3. Spring JUnit 4 测试注解
下面的注解仅在与 [SpringRunner](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit4-runner) ，[Spring's JUnit 4 rules](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-junit4-rules) ,或者[Spring’s JUnit 4 support classes](https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#testcontext-support-classes-junit4) 配合使用时才有效：  
* `@IfProfileValue`
* `@ProfileValueSourceConfiguration`
* `@Timed`
* `@Repeat`

#### `IfProfileValue`
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

#### `@ProfileValueSourceConfiguration`
它是一个类级别的注解，它指定了当通过`@IfProfileValue`注解检索配置值的时候该使用什么类型的`ProfileValueSource`。如果该注解没有在测试上声明，`SystemProfileValueSource`会被作为默认值。  

使用实例：
```java
@Test
@ProfileValueSourceConfiguration(CustomProfileValueSource.class)
public class CustomProfileValueSourceTests(){}
```

#### `@Timed`
`@Timed`代表备注接的测试方法必须在指定的时间段内完成（微秒）。如果测试时间超过了指定的时间段，则测试失败。  

这个时间段包括运行测试方法自身的时间，以及重复测试的时间（`@Repeat`)，也包括其他测试资源的安装和卸载时间。

```java
@Timed(millis = 1000)
public void testProcessWithOneSecondTimeout(){
}
```
Spring的`@Timed`语法跟JUnit4的语法`@Test(timeout=...)`不同，是因为JUnit4处理测试执行超时的处理方式（在单独的一个分支执行测试方法），如果测试超时`@Test(timeout=...)`会立即让测试失败。但Spring的`@Timed`不同，在标识失败之前，他会让测试方法先走完。  

#### `@Repeat`
它代表注解的测试方法必定会重复执行。重复执行的次数需要指定在注解参数中  

除了重复执行测试方法本身，测试资源的安装和卸载也会被重复执行。

```java
@Repeat(10)
@Test
public void testProcessRepeatedly(){}
```

### 4.4. Spring JUnit Jupiter 测试注解
下面的注解只在配合`SpringExtension`和JUnit Jupiter(也就是JUnit5的编程模型)使用时才可用
* `@SpringJUnitConfig`
* `@SpringJUnitWebConfig`
* `@TestConstructor`
* `@NestedTestConfiguration`
* `@EnabledIf`
* `@DisabledIf`  

#### `@SpringJUnitConfig`
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



