---

    title: "@Cacheable指定ttl"
    date: 2020-05-09
    tags: ["spring"]

---

根据配置

应用实例：  
```java

/**
 * 默认 defaultManager ttl:1天
 */
@Cacheable(cacheNames = "firstCache")
public Data prepareCache(String key) {
        ...
}

/**
 * ttl:30天
 */
@Cacheable(cacheNames = "SecondCache", cacheManager = "ttl30Days")
public Data prepareCache(String key) {
        ...
}

/**
 * ttl:1小时
 */
@Cacheable(cacheNames = "thirdCache", cacheManager = "ttlOneHour")
public Data prepareCache(String key) {
        ...
}
```


配置实例：
```java
@Configuration
public class CacheManager {

    @Value("${spring.cache.redis.time-to-live:3600000}")
    private long ttl;

    @Value("${spring.cache.redis.key-prefix:test}")
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
    public RedisCacheManager ttl30Seconds(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofSeconds(30));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }

    @Bean
    public RedisCacheManager ttl30Minutes(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofMinutes(30));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }

    @Bean
    public RedisCacheManager ttlOneHour(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofHours(1));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }

    @Bean
    public RedisCacheManager ttlOneDay(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofDays(1));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }

    @Bean
    public RedisCacheManager ttl30Days(RedisCacheWriter redisCacheWriter) {
        RedisCacheConfiguration cacheConfiguration =
                defaultConfig()
                        .entryTtl(Duration.ofDays(30));
        return new RedisCacheManager(redisCacheWriter, cacheConfiguration);
    }


    @Bean
    public RedisCacheWriter redisCacheWriter(RedisConnectionFactory connectionFactory) {
        return RedisCacheWriter.lockingRedisCacheWriter(connectionFactory);
    }


    @NotNull
    private RedisCacheConfiguration defaultConfig() {
        //序列化
        RedisSerializationContext.SerializationPair<Object> valueSerializationPair = RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer());
        return RedisCacheConfiguration.defaultCacheConfig()
                        .serializeValuesWith(valueSerializationPair)
                //缓存key格式：[prefix]::[cacheName]::[keys]
                .computePrefixWith(cacheName ->
                                (usePrefixKey ? String.format("%s::", prefixKey) : "")  + String.format("%s::", cacheName)
                        );
    }
}
```