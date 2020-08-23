---
title: "Mysql启动报错mkdir: cannot create directory ‘//.cache’: Permission denied"
date: 2020-08-10T14:52:32+08:00
tags: ["mysql"]

---

```shell script
usermod -d /var/lib/mysql/ mysql
ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
chown -R mysql:mysql /var/lib/mysql
```
