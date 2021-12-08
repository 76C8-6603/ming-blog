---

    title: "Spring多个同类型bean的优先级"
    date: 2021-12-08
    tags: ["spring"]

---

### @Primary

标注多个同类型bean中，Autowire首先考虑的bean

```java

@Component
public class FooService {

    private FooRepository fooRepository;

    @Autowired
    public FooService(FooRepository fooRepository) {
        this.fooRepository = fooRepository;
    }
}

@Component
public class JdbcFooRepository extends FooRepository {

    public JdbcFooRepository(DataSource dataSource) {
        // ...
    }
}

@Primary
@Component
public class HibernateFooRepository extends FooRepository {

    public HibernateFooRepository(SessionFactory sessionFactory) {
        // ...
    }
}
```

由于`@primary`注解`FooService`中注入的就是`HibernateFooRepository`

### @ConditionalOnMissingBean

如果该类型的bean在别处没有申明，那么Autowire才会注入该注解修饰的bean

```java

@Configuration
public class MyAutoConfiguration {

    @ConditionalOnMissingBean
    @Bean
    public MyService myService() {
           ...
    }

}
```
如果在别处没有任何`MyService`的声明，才会选择该bean注入