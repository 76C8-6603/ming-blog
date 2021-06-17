---

    title: "HUE Kerberos Ticket Renewer无法启动"
    date: 2021-06-17
    tags: ["CDH"]

---

# 解决方案
查看`/var/kerberos/krb5kdc/kdc.conf`  
* 如果有`ticket_lifetime = 10m`注释掉。  
* 在realms对应的域名下添加`max.renewable.life = 90d 0h 0m 0s`