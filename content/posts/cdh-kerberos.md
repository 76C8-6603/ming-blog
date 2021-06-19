---

    title: "CDH 配置 kerberos"
    date: 2021-06-17
    tags: ["CDH","kerberos"]

---

> 参考[cdh6.3.1开启kerberos](https://blog.eric7.site/2019/12/30/cdh6-3-1%E5%BC%80%E5%90%AFkerberos/)  

注意文章存在几处问题需要注意：  
* `kbc5.conf`无法生效，改名称为`krb5.conf`
* 注意`kbc5.conf`中的`realms`配置，博主写的master是hosts别名，需要改为当前安装kbc和admin_server的机器ip，如果默认端口号不是88，还需要指定端口
* 注意`hive/cdh-1@TSINGJ.COM`其中`cdh-1`是主机名