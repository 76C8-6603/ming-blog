---

    title: "大数据相关常用命令备忘"
    date: 2021-06-17
    tags: ["hadoop","hive","kerberos"]

---

## kerberos
kerberos续约
```shell
sudo - testuser
# 验证用户
kinit testuser
# 续期
kinit -R
# 查看过期时间
klist
```
其他
```shell
# kerberos数据库创建
kdb5_util create –r EXAMPLE.COM -s

# 用户创建 例：进入交互界面后指定用户名test `addprinc test@EXAMPLE.COM`
kadmin.local 

# 查看当前kerberos的所有用户
kadmin.local -q "listprincs"

# 清理登陆缓存
kdestroy

# 验证登陆用户
kinit user1

# 查看当前验证登录用户的有效期
klist

# 生成keytab
cd /var/kerberos/krb5kdc/
kadmin.local -q "addprinc -randkey hive/h1@CAT.COM "
kadmin.local -q "addprinc -randkey hive/h2@CAT.COM "
kadmin.local -q "xst  -k hive.keytab  hive/h1@CAT.COM "
kadmin.local -q "xst  -k hive.keytab  hive/h2@CAT.COM "

# 使用指定keytab文件验证并登陆
kinit -kt hive.keytab hive/h1

```

## hadoop

```shell
# 测试demo
hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 10 1
```

## hive

```shell
# 连接本地hive
hive

# 连接指定hive
beeline
beeline> !connect jdbc:hive2://localhost:10000/;principal=hive/CDH-1@EXAMPLE.COM
```