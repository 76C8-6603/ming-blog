---
    title: "SpringBoot Redis集成"
    date: 2018-09-05
    tags: ["redis","spring"]
    
---

#### application.yml
```yaml
spring:
  redis:
    database: 0
    host: localhost
    prot: 6379
    pool:
      max-active: 8
      max-wait: -1
      max-idle: 8
      min-idle: 0
    timeout: 0
```
更多配置参考[Spring官网配置参数](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-application-properties.html#core-properties)  

#### RedisConfig
```java
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport {

    @Bean
    @Override
    public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory) {
        return RedisCacheManager.create(redisConnectionFactory);
    }

}

```