---

    title: "Redis实现的分布式锁"
    date: 2020-08-25
    tags: ["redis"]
    draft: true
---

按照Redis官方的说法，Redis实现的分布式锁需要确保下面三个属性：  
1. 安全性：互斥，在指定时间点，只能有一个客户端持有锁；
2. 存活性A：不能有死锁。就是始终能获取到一个锁，即使客户端锁定的资源崩溃或者被分区；
3. 存活性B：容错能力。只要大多数Redis节点还在运行，客户端就能获取和释放锁。  

在单实例Redis的情况下实现分布式锁是比较简单的，直接通过SET一个客户端的唯一标识值，并给他设定超时时间即可。  
但是在多实例的情况下，这种实现方案是有致命缺陷的。假如出现下面的情况：  
1. 客户端A在master获取锁
2. 在master把该key同步到slave之前，master崩溃了
3. slave晋升为master
4. 客户端B在这个时候获取的相同的资源，但是在新的master中没有对应key  

这种情况下相当于客户端AB都拿到了锁，违背了之前讲到的第一个属性：安全性。  

下面是单实例Redis具体是怎么实现分布式锁的
### 单实例Redis
首先是获取锁
```shell
SET resource_name my_random_value NX PX 30000
```
NX代表只能在没有对应key的时候才能设置成功，PX代表无论怎样该key都会在30000毫秒后失效。  
注意这里要确保`my_random_value`值的唯一性。  

除了超时释放锁，客户端也会主动释放锁，主动释放锁通过lua脚本实现：  
```lua
if redis.call("get",KEYS[1]) == ARGV[1] then
    return redis.call("del",KEYS[1])
else
    return 0
end
```
这样写的原因是确保客户端删的是自己的锁。  

### 多实例Redis
Redis的多实例分布式锁，Redis称这个算法为Redlock。  
这里假定有N个Redis的master节点，并且这些节点都是独立的，因此没有使用复制或者其他隐性的协作系统。  
在这个方法里我们设定这个N为5


Redlock有多种语言实现，其中java实现叫做redisson    
[Redlock java implementation](https://github.com/redisson/redisson)

> 参考[redis distributed lock](https://redis.io/topics/distlock)