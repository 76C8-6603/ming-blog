---

    title: "centos openssl-libs downgrade"
    date: 2021-06-16
    tags: ["linux"]

---
# 异常
```shell
错误：软件包：1:openssl-1.0.2k-19.el7.x86_64 (centos)
          需要：openssl-libs(x86-64) = 1:1.0.2k-19.el7
          已安装: 1:openssl-libs-1.0.2k-21.el7_9.x86_64 (@updates)
              openssl-libs(x86-64) = 1:1.0.2k-21.el7_9
          可用: 1:openssl-libs-1.0.2k-19.el7.x86_64 (centos)
              openssl-libs(x86-64) = 1:1.0.2k-19.el7
错误：软件包：zlib-devel-1.2.7-18.el7.x86_64 (centos)
          需要：zlib = 1.2.7-18.el7
          已安装: zlib-1.2.7-19.el7_9.x86_64 (@updates)
              zlib = 1.2.7-19.el7_9
          可用: zlib-1.2.7-18.el7.x86_64 (centos)
              zlib = 1.2.7-18.el7
```

# 原因
做本地仓库之前执行过`yum update`，但是本地仓库用的是原版iso镜像，版本跟系统实际版本对不上。

# 解决方案
```shell
# 查看重复的安装，如果只有一个，那么这个解决方案无效
yum list openssl-libs --show-duplicates
yum list zlib --show-duplicates
```

```shell
# 执行降级
yum downgrade openssl-libs
yum downgrade zlib
```