---
    title: "SpringBoot Mybatis配置多数据源"
    date: 2018-9-10
    tags: ["spring"]
    
---

```java
@Configuration
@MapperScan(basePackages = MysqlDatasourceConfig.PACKAGE, sqlSessionFactoryRef = "mysqlSessionFactory")
public class MysqlDatasourceConfig {

    public static final String PACKAGE = "com.ming.mapper.mysql1";
    public static final String MAPPER_LOCATION = "classpath:mapper/mysql1/*.xml";

    @Primary
    @Bean(name = "mysqlDatasource")
    @ConfigurationProperties("spring.datasource.druid.mysql1")
    public DataSource mysqlDataSource(){
        return DruidDataSourceBuilder.create().build();
    }

    @Bean(name = "mysqlTransactionManager")
    @Primary
    public DataSourceTransactionManager mysqlTransactionManager() {
        return new DataSourceTransactionManager(mysqlDataSource());
    }

    @Bean(name = "mysqlSessionFactory")
    @Primary
    public SqlSessionFactory mysqlSessionFactory(@Qualifier("mysqlDatasource") DataSource dataSource) throws Exception {
        final SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource);
        sessionFactory.setMapperLocations(new PathMatchingResourcePatternResolver().getResources(MysqlDatasourceConfig.MAPPER_LOCATION));
        return sessionFactory.getObject();
    }

}
```
##### 配置文件中有多少个数据源就新建多少个上面的配置类  
##### 配置类中设置了当前数据源对应的mapper路径和xml路径  
##### 在service中使用时，只需要调用对应的mapper即可