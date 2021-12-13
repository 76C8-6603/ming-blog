---

    title: "Mysql 一直新增 Sleep Process"
    date: 2021-07-22
    tags: ["mysql"]

---

记录一次排查Mysql Process一直新增的问题

### 背景
Spring Boot项目部署到k8s上，Mysql连接进程一直新增，最开始以为是服务连接池问题。druid连接池配置：
```yaml
datasource:
    # druid连接池驱动配置信息
    type: com.alibaba.druid.pool.DruidDataSource
    druid:
      #mysql 配置
      driver-class-name: com.mysql.cj.jdbc.Driver
      url: jdbc:mysql://${MYSQL_URL:localhost:3307}/test_db?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
      username: root
      password: root
      #连接池建立时创建的初始化连接数
      initial-size: 5
      #连接池中最大的活跃连接数
      max-active: 20
      #连接池中最小的活跃连接数
      min-idle: 5
      # 配置获取连接等待超时的时间
      max-wait: 60000
      # 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
      time-between-eviction-runs-millis: 60000
      # 配置一个连接在池中最小生存的时间，单位是毫秒
      min-evictable-idle-time-millis: 300000
      # 打开PSCache，并且指定每个连接上PSCache的大小
      pool-prepared-statements: true
      max-pool-prepared-statement-per-connection-size: 20
      #spring.datasource.druid.max-open-prepared-statements= #和上面的等价
      validation-query: SELECT 1 FROM DUAL
      validation-query-timeout: 30000
      #是否在获得连接后检测其可用性
      test-on-borrow: false
      #是否在连接放回连接池后检测其可用性
      test-on-return: false
      #是否在连接空闲一段时间后检测其可用性
      test-while-idle: true
      # 通过connectProperties属性来打开mergeSql功能；慢SQL记录
      connection-properties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
      # 合并多个DruidDataSource的监控数据
      use-global-data-source-stat: true
        # 配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
        #filters: stat,wall,log4j
      #web-stat-filter:
      #enabled: false
```

Mysql查看连接进程  
```sql
-- 根据Database获取连接的进程
SELECT * FROM information_schema.PROCESSLIST WHERE DB = 'test_db';
-- 或者通过以下命令获取全部进程
SHOW PROCESSLIST;
```
展示结果如下
```
+-------+------+---------------------+--------------+---------+------+-------+------+
| ID    | USER | HOST                | DB           | COMMAND | TIME | STATE | INFO |
+-------+------+---------------------+--------------+---------+------+-------+------+
| 14629 | root | 1.1.1.1:65193   | test_db | Sleep   | 4001 |       | NULL |
| 14635 | root | 1.1.1.1:14802   | test_db | Sleep   | 3912 |       | NULL |
| 14753 | root | 1.1.1.1:42344   | test_db | Sleep   |  309 |       | NULL |
| 14745 | root | 1.1.1.1:1564    | test_db | Sleep   |  463 |       | NULL |
| 14742 | root | 1.1.1.1:59856   | test_db | Sleep   |  541 |       | NULL |
| 14636 | root | 1.1.1.1:9010    | test_db | Sleep   | 3910 |       | NULL |
| 14628 | root | 1.1.1.1:35523   | test_db | Sleep   | 4017 |       | NULL |
| 14688 | root | 1.1.1.1:10166   | test_db | Sleep   | 2092 |       | NULL |
| 14679 | root | 1.1.1.1:29436   | test_db | Sleep   | 2226 |       | NULL |
| 14750 | root | 1.1.1.1:27896   | test_db | Sleep   |  355 |       | NULL |
| 14632 | root | 1.1.1.1:30719   | test_db | Sleep   | 3938 |       | NULL |
| 14743 | root | 2.2.2.2:44124 | test_db | Sleep   |  518 |       | NULL |
| 14744 | root | 2.2.2.2:44126 | test_db | Sleep   |  518 |       | NULL |
+-------+------+---------------------+--------------+---------+------+-------+------+
```

### 解决方案
可以通过`kill {ID}`命令杀掉指定进程，但是很快又会有大量process填充进来，不能从根源解决问题  
另一个方法是通过设置进程超时来进行限制，Mysql Sleep Process是有超时时间的，超过指定的时间会被自动杀掉，默认时间是8天，可以通过以下命令查看：
```sql
show variables like 'wait_timeout';
```
```
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| wait_timeout  | 28800 |
+---------------+-------+
```
单位是秒，也就是8天  
可以通过缩短超时时间来限制mysql process的数量：  
```sql
-- 这里设置为五分钟
-- 全局
SET GLOBAL wait_timeout = 300;
-- 当前session
SET SESSION wait_timeout = 300;
```
> 注意修改当前session配置后，查看结果可能还是8天，是因为`wait_timeout`的值，会根据连接方式的不同，获取不同的参数。如果是 `interactive` 连接，会读取`interactive_timeout`的值。具体可参考[Mysql 官方文档](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_wait_timeout)  

> 重启后会恢复默认，可通过修改conf文件持久化。`sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf`，修改`[mysqld]wait_timeout = 300`  

但是到这里虽然能解决问题，但是原因仍未找到  
通过分析HOST发现，IP只有`1.1.1.1`和`2.2.2.2`，经过确认`2.2.2.2`是线上服务pod的ip，数量正常，证明服务线程池配置没有问题    

问题就出在`1.1.1.1`这个IP上，所有到Mysql服务的外部请求都会经过统一转发，这个IP并不是真实IP，但可以肯定不是线上pod的请求  
最后经过逐一排查，发现只有本地`IDEA的数据库工具`在连接这个库，并且会不定时的创建新连接。。。  
在disconnect后，问题不再复现（IDEA不定时创建连接的问题还未确定，但相同的工具本地数据库不会复现，目前怀疑是数据连接不稳定导致）    
目前采用临时解决方案，换了一个开源DB工具（DBeaver）