---

    title: "Cannot contact any KDC for realm while getting initial credentials"
    date: 2021-06-17
    tags: ["kerberos"]

---

# 背景
执行`kinit`命令报错：  
```log
Cannot contact any KDC for realm while getting initial credentials
```

# 原因
无法解析`/etc/krb5.conf`配置的域名  

# 解决方案
修改`/etc/krb5.conf`文件对应位置
```editorconfig
[realms]
  EXAMPLE.COM = {
    kdc = master
    admin_server = master
  }
```
kdc和admin_server是能够访问的域名地址，查看hosts配置，或者直接修改为ip，并且注意对应端口如果kbc和admin_server不是默认端口88，需要手动指定。  

> 参考官方文档[krb5_conf realm](http://web.mit.edu/Kerberos/krb5-1.12/doc/admin/conf_files/krb5_conf.html#realms)