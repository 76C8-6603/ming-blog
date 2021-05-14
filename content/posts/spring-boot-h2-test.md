---

    title: "Spring boot h2集成数据库进行测试"
    date: 2018-10-22
    tags: ["spring","h2","test"]

---

# 背景
使用`AutoConfigure*`或者`SpringBootTest`进行测试的时候，如果不手动设置`@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)`，那么SpringBoot会默认在classpath下寻找集成数据库。  
集成数据库可以直接通过初始化脚本，在没有数据库环境的情况下，就能进行功能测试。并且你不需要对集成数据库进行任何配置。  

# Spring boot 集成h2
想要使用spirngboot集成的h2，只需要引入依赖：  
```xml
<dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
</dependency>
```
在`properties`文件中，不需要任何配置（当然也可以手动指定）Springboot就能直接使用h2。  
如果想自己配置h2，以替换Spring-boot集成的，可以进行如下配置：  
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=false;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE;MODE=MYSQL
  test:
    database:
      replace: NONE
```
注意，因为有`test.database.replace=NONE`的存在，不需要在测试类上再申明`@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)`

# 实例
下面是一个测试类的父类(基于Junit5)，是在所有测试之前初始化表结果和测试数据
```java
@AutoConfigureTestDatabase
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class SuperTestConfiguration {

    @Autowired
    private DataSource dataSource;

    @BeforeAll
       void beforeAll() {
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScripts(
                new ClassPathResource("/sql/h2/init/init.sql"),
                new ClassPathResource("/sql/h2/test/test.sql"));
        populator.setSeparator(";");
        populator.execute(dataSource);
    }
}
```
