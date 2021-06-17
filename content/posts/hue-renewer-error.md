---

    title: "HUE Kerberos Ticket Renewer无法启动"
    date: 2021-06-17
    tags: ["CDH"]

---

# 解决方案
查看`/var/kerberos/krb5kdc/kdc.conf`  
* 如果有`ticket_lifetime = 10m`注释掉。  

执行命令
```shell
kadmin.local -q "modprinc -maxrenewlife 90day krbtgt/EXAMPLE.COM@EXAMPLE.COM"
kadmin.local -q "modprinc -maxrenewlife 90day allow_renewable hue/cdh-1@EXAMPLE.COM"
```