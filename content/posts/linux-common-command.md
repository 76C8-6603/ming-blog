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

# 创建一个软连接到指定目录，相当于快捷方式
ln -s ~/test.sh /etc/test/

find / -name web.xml #查看名字为web.xml的文件，需要等待片刻

find .|xargs grep -rl "google.com" #搜索当前目录文件内容并返回文件名

find .|xargs grep -r "google.com"  #搜索当前目录文件内容并返回文件名，并展示命中行

find .|xargs grep -rn "google.com" #搜索当前目录文件内容并返回文件名，并展示行号

find .|xargs grep -rn1 "google.com" #搜索当前目录文件内容并返回文件名，并展示上下文内容

# 查看文件的最后一百行 -f 属性循环读取
tail -n 100 cata.log 
# 查看文件中过滤内容（忽略大小写）的前后五行
tail -n 40 -f cata.log|grep -i 'error' -5

# 创建文件夹
mkdir -p 
# 创建多个子目录
mkdir -p test/{sql,scripts}

cat [目录1]  >> [目录2] #把目录1的文件内容输入到目录2中 

chmod a+x filename #让执行文件能被./filename调用

#将当前目录下的所有文件移到上层目录，以便删除上级目录
mv * ../

#HOST修改需重启
vi /etc/hosts 

#DNS修改即时生效
vi /etc/resolv.conf 

#IP修改需重启
vi /etc/sysconfig/network-scripts/ifcfg-eth0 

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

# 实时查看资源占用情况
top 

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


# 根据jps查出的对应id，跳转到指定目录，ll找到log日志文件
cd /proc/[jps id]/fd

# 生成SSH key
ssh-keygen 

# 设置免密登陆，前提是已执行ssh-keygen
ssh-copy-id root@192.168.100.100

#在目录下查找循环引用
find -L ./ -mindepth 15

# 定时任务
sudo crontab -e

# 查询对应端口的service
sudo netstat -plant | grep 80

# 检查服务的状态
systemctl status nginx

# 可以解决一些服务不可见的问题
systemctl daemon-reload

# 启动，终止，和重启进程
systemctl start mongod
systemctl stop mongod
systemctl restart mongod

# 让进程随系统自启动
systemctl enable mongod

# centos7 防火墙添加端口
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# centos7 查看所有现有规则
firewall-cmd --list-ports

# centos7 开启端口区间
firewall-cmd --zone=public --add-port=4400-4600/tcp --permanent

# 查看端口占用情况
netstat -tunlp | grep 8080

# 查看主机名称
hostname

# 修改主机名称
hostnamectl set-hostname custom-host

# 挂载镜像
mount -o loop *.ios /mnt

# 取消挂载
umount /mnt

# centos/redhat 升级历史
yum history

# centos/redhat 升级回滚
yum history undo {history id}

# centos/redhat 展示所有重复的安装
yum list openssl-libs --show-duplicates

# 降级指定的软件
yum downgrade openssl-libs

# 实时修改内核运行参数
sysctl vm.swappiness=10

# 查看内存占用
free -m

# 清理内存
echo 1 > /proc/sys/vm/drop_caches

# 树形结构查看目录
tree /etc

# 将source的内容追加到target内容之后
cat source.csv >> target.csv

# 统计文件行数。还有其他选项：-c统计字节数，-m统计字符数，-w统计字数，-L打印最长行的长度
wc -l target.csv

# 磁盘占用情况，挂载情况
df -h

# 查看哪个目录占用空间最大
du -s /* | sort -nr

# 查看当前目录下文件大小情况
du -h --max-depth=1

# 查看删除的文件是否被进程占用
lsof | grep deleted

# 登录没有shell的服务账号，比如jenkins
sudo su -s /bin/bash jenkins

# 文件校验sha-256
shasum -a 256 web.jar

# 删除已输入命令
control/ctrl + c

# 删除光标前的所有命令
control/ctrl + u

# 往回删除一个单词
control/ctrl + w

# 删除光标以后的单词
control/ctrl + k

# 移动光标到命令头
control/ctrl + a

# 移动光标到命令尾
control/ctrl + e

# 清屏
control/ctrl + l

# chroot new root directory
mkdir -p new-root/{bin,lib64}
cp /bin/bash new-root/bin
cp /lib64/{ld-linux-x86-64.so*,libc.so*,libdl.so.2,libreadline.so*,libtinfo.so*} new-root/lib64
sudo chroot new-root
```
