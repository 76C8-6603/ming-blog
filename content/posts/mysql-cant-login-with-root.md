---
    title: "Mysql安装后root无法登陆(Access denied for user 'root'@'localhost')"
    date: 2018-06-08
    tags: ["mysql"]
    
---

复杂密码才能通过
```shell script
sudo mysql -u root -p
mysql> select user, plugin from mysql.user;
mysql> update mysql.user set authentication_string=PASSWORD('xcvds_32GDS'), plugin='mysql_native_password' where user='root';
```
mysql8.0不能用上边的语句：
```shell script
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY "svewe_123";
```