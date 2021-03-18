---
    title: "Redis常用命令"
    date: 2018-06-22
    tags: ["redis"]
    draft: true    
---

客户端指令
```redis
#获取指定key的值
GET key 

#删除指定key的键值
DEL key 

#列出所有key
KEYS *  

#模糊匹配所有key
KEYS user*  

# 设置键值
# EX 指定超时时间，单位秒
# PX 指定超时时间，单位毫秒
# EXAT 指定Unix时间超时，单位秒
# PXAT 指定Unix时间超时，单位毫秒
# nx 代表对应key值不存在时成功，xx相反，代表对应key值存在时成功
# KEEPTTL 保留与key值关联的生存时间
# GET 返回set前的旧值，如果key不存在就是nil
SET key value [EX seconds] [PX milliseconds] [EXAT timstamp-seconds] [PXAT timestamp-milliseconds] [KEEPTTL]  [nx/xx] [GET]


```
详细参考[redis commands](https://redis.io/commands)

linux命令
```shell
# 校验AOF文件
# 如果存在被截断的指令会被删除，老版本需要执行，新版本默认会忽略被截断的指令
# 如果是有无效的字节码在中间，可以选择删掉--fix选项，手动修复。或者加上--fix选项自动修复，但是这会造成从无效字节码开始到文件尾的大量数据丢失
redis-check-aof --fix <filename>
```

