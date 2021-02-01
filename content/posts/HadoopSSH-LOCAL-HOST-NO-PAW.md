---
    title: "Hadoop ssh localhost 无密码登录"
    date: 2019-12-09
    tags: ["hadoop"]
    
---

首先确保安装SSH server：
```shell script
sudo apt-get install openssh-server
```
启动SSH server:
```shell script
sudo service ssh start
#检查ssh是否正常启动
ssh localhost
```

安装后，可以使用如下命令登陆本机：
```shell script
ssh localhost
```
此时会有SSH首次登陆提示，输入 yes 。然后按提示输入密码 hadoop，这样就登陆到本机了。

但这样登陆是需要每次输入密码的，我们需要配置成SSH无密码登陆。

有以下两种实现方法：

　　一、首先退出刚才的 ssh，就回到了我们原先的终端窗口，然后利用 ssh-keygen 生成密钥，并将密钥加入到授权中：

```shell script
# 退出刚才的 ssh localhost
exit
# 若没有该目录，请先执行一次ssh localhost
cd ~/.ssh/
# 会有提示，都按回车就可
ssh-keygen -t rsa
# 加入授权
cat ./id_rsa.pub >> ./authorized_keys 
```
　　二、　  
```shell script
#1
ssh localhost
```
```shell script
#2
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
```
```shell script
#3
ssh localhost
```
```shell script
#4 要保证：~/.ssh需要是700权限 authorized_keys需要是644权限
chmod 700 ~/.ssh
chmod 644 ~/.ssh/authorized_keys
```
```shell script
#5 此时进入到~/.ssh目录下，会看到多了一个文件know_hosts文件
```
```shell script
#6 退出exit，重新打开shell
```
```shell script
#7.最后ssh localhost验证一下
```
　　　　