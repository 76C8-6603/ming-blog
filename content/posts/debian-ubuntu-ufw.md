---

    title: "ufw指令简介"
    date: 2018-09-21
    tags: ["linux"]

---

ufw指令是ubuntu/debian体系的防火墙指令，它对原本的iptables指令进行了封装，对比iptables指令，ufw更加简洁有效。  
```shell
# 重置防火墙
sudo ufw reset

# 查看防火墙状态
sudo ufw status [verbose]

# 改变防火墙规则后都需要执行一次reload
sudo ufw reload

# 启用防火墙
sudo ufw enable

# 禁用防火墙
sudo ufw disable

# 允许端口3306的访问
sudo ufw allow 3306

# 禁止端口22的访问
sudo ufw deny 22

# 允许服务层的访问
sudo ufw allow OpenSSH

# 禁止服务层的访问
sudo ufw deny OpenSSH

# 列出所有可用的服务
sudo ufw app list

# 允许来自指定ip的访问
sudo ufw allow from 192.188.23.2

# 禁止来自某个ip的访问
sudo ufw deny from 192.168.1.2

# 指定允许访问的协议
sudo ufw allow 80/tcp

# 禁止访问的协议
sudo ufw deny 80/udp

# 对不同网卡进行限制
sudo ufw allow in on eth0 to any port 80

# 允许端口上行
sudo ufw allow in 80

# 允许端口下行
sudo ufw deny out 3389

# 限制6次ssh在30秒之内
sudo ufw limit ssh

# 明确拒绝连接
sudo ufw reject 666

# 删除指定规则
sudo ufw delete allow 80

# 展示规则编号，可以直接用于删除
sudo ufw status numbered

# 规则注释
sudo ufw allow 22 comment 'for my SSH'

# 维护日志
sudo ufw logging on

# 允许Nginx的所有端口
sudo ufw allow 'Nginx Full'

# 展示所有规则带序号　
sudo ufw status numbered

# 删除指定序号规则
sudo ufw delete 9
```