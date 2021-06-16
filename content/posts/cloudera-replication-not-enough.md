---

    title: "cloudera 副本不足的块"
    date: 2021-06-16
    tags: ["hadoop","CDH"]

---

# 原因
集群中的dataNode数量要跟副本数量对应

# 解决方案
hdfs 配置 -> 搜索dfs.replication，修改为dataNode的实际数量

修改后，还需手动刷新，对应数字就是dataNode的实际数量
```shell
sudo -u hdfs hadoop fs -setrep -R 2 / 
```