---

    title: "Spring @Cacheable 自定义缓存key（key-prefix覆盖cahcheNames如何解决）"
    date: 2020-04-27
    tags: ["spring", "redis"]

---

利用`RedisCacheConfiguration.defaultCacheConfig().computePrefixWith`即可自定义cacheName的生成策略  
> 参考[redis issue](https://github.com/spring-projects/spring-data-redis/issues/1614)  

以下是具体的`Configuration`
```java
@Configuration
public class CacheManager {

    @Value("${spring.cache.redis.time-to-live:3600000}")
    private long ttl;

    @Value("${spring.cache.redis.key-prefix:ware}")
    private String prefixKey;

    @Value("${spring.cache.redis.user-key-prefix:true}")
    private boolean usePrefixKey;

    @Primary
    @Bean
    public RedisCacheManager defaultManager(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofMillis(ttl));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }


    @Bean
    public RedisCacheWriter redisCacheWriter(RedisConnectionFactory connectionFactory) {
        return RedisCacheWriter.lockingRedisCacheWriter(connectionFactory);
    }


    @NotNull
    private RedisCacheConfiguration defaultConfig() {
        RedisSerializationContext.SerializationPair<Object> valueSerializationPair = RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer());
        return RedisCacheConfiguration.defaultCacheConfig()
                        .serializeValuesWith(valueSerializationPair)
                //缓存名称生成策略：[prefix]::[cacheName]::[keys]
                        .computePrefixWith(cacheName ->
                                (usePrefixKey ? String.format("%s::", prefixKey) : "")  + String.format("%s::", cacheName)
                        );
    }
}
```
