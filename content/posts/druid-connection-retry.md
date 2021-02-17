---
    title: "Druid数据库连接失败，无限尝试问题"
    date: 2020-06-16T15:38:20+08:00
    tags: ["druid"]
    
---

需提前设置BreakAfterAcquireFailure为true，不然连接重试次数限制无效
还需要设置FailFast为true，不然原始线程会一直阻塞
    
```java
dataSource.setBreakAfterAcquireFailure(true);
dataSource.setFailFast(true);
dataSource.setConnectionErrorRetryAttempts(3);
```