---
    title: "为服务开启BBR加速"
    date: 2019-05-31T19:03:55+08:00
    tags: ["linux"]
    
---

脚本：
```shell script
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh
```
查看结果：
```shell script
sysctl net.ipv4.tcp_available_congestion_control
```