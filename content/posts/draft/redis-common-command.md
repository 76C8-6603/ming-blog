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
KEYS *  #列出所有key
KEYS user*  #模糊匹配所有key

```

linux命令
```shell
# 校验AOF文件
# 如果存在被截断的指令会被删除，老版本需要执行，新版本默认会忽略被截断的指令
# 如果是有无效的字节码在中间，可以选择删掉--fix选项，手动修复。或者加上--fix选项自动修复，但是这会造成从无效字节码开始到文件尾的大量数据丢失
redis-check-aof --fix <filename>
```

详细参考[redisdoc](http://redisdoc.com/)
