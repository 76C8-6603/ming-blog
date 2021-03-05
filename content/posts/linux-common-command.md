---
    title: "Linux常用命令备忘"
    date: 2018-08-14 
    tags: ["linux"]
    
---


```shell script
cd - #查看上一次所在的目录

cat /etc/hosts  #文档查看

ls  #查看当前目录下所有文件

pwd #查看当前目录的绝对路径

ll #查看目录下文件的详细信息，包括权限属组等信息

find / -name web.xml #查看名字为web.xml的文件，需要等待片刻

find .|xargs grep -rl "google.com" #搜索当前目录文件内容并返回文件名

find .|xargs grep -r "google.com"  #搜索当前目录文件内容并返回文件名，并展示命中行

find .|xargs grep -rn "google.com" #搜索当前目录文件内容并返回文件名，并展示行号

find .|xargs grep -rn1 "google.com" #搜索当前目录文件内容并返回文件名，并展示上下文内容

mkdir -p #创建文件夹

cat [目录1]  >> [目录2] #把目录1的文件内容输入到目录2中 

chmod a+x filename #让执行文件能被./filename调用

mv #文件移动或者重命名

#将当前目录下的所有文件移到上层目录，以便删除上级目录
mv * ../

vi /etc/hosts #HOST修改需重启

vi /etc/resolv.conf #DNS修改即时生效

vi /etc/sysconfig/network-scripts/ifcfg-eth0 #IP修改需重启

cat /etc/os-release #查看当前系统版本信息

# 把dir1完整复制到dir2
cp -r dir1 dir2

# 把dir1下的所有子文件复制到dir2，不包括目录自身
cp -r dir1/. dir2

unset #删除对应的环境变量

nslookup [ip/域名] #通过域名查找ip和dns，或者通过ip查找域名

wget 域名  #通过指定域名下载文件到当前目录

scp -r ~/data root@127.0.0.1:~/data #指定服务上传  

scp -r root@127.0.0.1:~/data ~/data #指定服务下载

ctrl+z #进程暂停

ctrl+c #进程终止

fg [JobID] #将后台进程移到前台处理，不设置id，将显示最后一个暂停的进程

bg [JobID] #将进程放到后台处理

jobs [选项] [JobID] #该命令生效之前需执行find / -name password &
    #-l显示进程
    #-p仅显示任务对应的进程号
    #-r仅输出运行状态的任务 
    #-s仅输出停止状态的任务
ps -ef  #查询所有正在运行的service
    ps -ef | grep mysql #查询mysql相关的进程
service --status-all  #查询所有已安装的service

reboot
    #-d重新开机时不把数据写入记录文件/var/tmp/wtmp。具有-n效果
    #-f强制重新开机，不调用shutdow指令
    #-i重新开机之前，关闭所有网络界面
    #-n重新开机之前不检查是否有程序未结束
    #-w仅做测试，不真正重启，只会在/var/log/wtmp写入记录
    
su - [用户名] #完全切换到指定用户，需要指定用户的密码

sudo  -i #暂时切换到root账户，logout命令可退出root，需要sudoers权限

sudo passwd root #设置root密码　

sudo useradd -m hadoop -s /bin/bash #添加用户

sudo adduser hadoop sudo #给用户追加管理员权限

top #表示1分钟，5分钟，15分钟的运行队列平均进程数

while true;do ps -u your-user-name -L | wc -l;sleep 1;done #查看当前用户开启的线程数

ulimit -u #查看当前用户所能开启的线程数

echo $JAVA_HOME #查询环境变量

which java #获取java执行路径

ls -lrt /usr/bin/java #查找安装路径

sudo tar -zxf 压缩包目录 -C 目标解压目录 #文件解压

sudo chown -R [userName] [filePath] #更改文件及其所有子文件的所有者权限

unzip #解压zip文件

vi /etc/apt/sources.list #编辑环境变量

dpkg -i *.deb #ubuntu体系安装软件包命令

apt-get upgrade [软件名] #ubuntu更新软件

jps #查看当前所有的java进程，并显示进程id

ssh-keygen #生成SSH key
```
