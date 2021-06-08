---

    title: "JOOQ常用的初始化配置"
    date: 2021-06-08
    tags: ["jooq"]

---
```java
Settings settings = new Settings();
//去掉别名的引号
settings.setRenderNameStyle(RenderNameStyle.AS_IS); settings.setRenderQuotedNames(RenderQuotedNames.NEVER);
Configuration configuration = new DefaultConfiguration().set(settings); 
//设置sql打印监听
configuration.set(new DefaultExecuteListenerProvider(new SqlLogListener(TITLE)));
//获取sql dialect
SQLDialect sqlDialect = dataSourceDef.getDataSourceType().getSqlDialectFamily();
configuration.set(sqlDialect); //数据源配置
//获取connection
try {
    Connection connection = ...;
    configuration.set(connection);
} catch (Exception e) {
    throw new NewOperatorException("获取数据库连接异常"); 
}
this.dslContext = DSL.using(configuration);
return this.dslContext;
```