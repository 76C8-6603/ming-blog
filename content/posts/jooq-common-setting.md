---

    title: "JOOQ常用的初始化配置"
    date: 2021-06-08
    tags: ["jooq"]

---
```java
Settings settings = new Settings();
//去掉别名的引号
settings.setRenderQuotedNames(RenderQuotedNames.NEVER);
Configuration configuration = new DefaultConfiguration().set(settings); 
//设置sql打印监听
configuration.set(new DefaultExecuteListenerProvider(new SqlLogListener()));
//获取sql dialect
configuration.set(SQLDialect.MYSQL); 
//获取connection
try {
    Connection connection = ...;
    configuration.set(connection);
} catch (Exception e) {}
this.dslContext = DSL.using(configuration);
```