---

    title: "hive 执行sql时报错out of sequence"
    date: 2018-09-23
    tags: ["hive"]

---

# 问题背景

错误日志：
```log
 org.apache.thrift.TApplicationException: [?] : out of sequence response
```

# 问题原因
hive连接在连接池中，同时两个线程去获取并执行，两个都有close操作。    
参考[hive jira](https://issues.apache.org/jira/browse/HIVE-6893)