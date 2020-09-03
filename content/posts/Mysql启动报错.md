---
title: "Mysql启动报错mkdir: cannot create directory ‘//.cache’: Permission denied"
date: 2017-07-11
tags: ["mysql"]

---

```shell script
usermod -d /var/lib/mysql/ mysql
ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
chown -R mysql:mysql /var/lib/mysql
```
