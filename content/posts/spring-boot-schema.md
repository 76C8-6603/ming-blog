---

    title: "Spring boot 启动时自动初始化sql脚本"
    date: 2020-11-13
    tags: ["spring"]

---

最简单的方式，是直接在资源目录下新建`schema.sql`和`data.sql`  
* `schema.sql`代表DDL
* `data.sql`代表DML  

默认情况下，在程序初始化的时候会为集成数据库执行，如果需要为spring.datasource中定义的数据库执行，需要修改以下属性：  
```properties
spring.datasource.initialization-mode=always
```
如果有多个版本的初始化脚本，那么spring-boot还提供了分类。需要你的sql脚本按照如下规则命名：  
* schema-${platform}.sql
* data-${platform}.sql

同时需要在属性中配置  
```properties
spring.datasource.platform=
```
默认情况下，脚本执行失败会导致spring-boot启动失败，可以通过配置属性跳过：  
```properties
spring.datasource.continue-on-error=
```

> 更多初始化脚本方式参考[howto-database-initialization](https://docs.spring.io/spring-boot/docs/2.1.18.RELEASE/reference/html/howto-database-initialization.html)
