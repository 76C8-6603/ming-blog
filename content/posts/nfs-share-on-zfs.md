---

    title: "NFS share on ZFS filesystem"
    date: 2023-02-04
    tags: ["linux"]

---

# Server(Ubuntu 22.04)
> 当前通过zfs命令分享的nfs版本是 version 3，但是version 3的最大传输速度只能到80MB/S。在6类网线和wifi6的支持下理论最高速度是110MB/S，想要达到这个速度，只能升级nfs4，但是windows和macos对nfs4的支持很差，nfs4和nfs3可以说是两个完全不一样的东西。  
> NF4有更快的速度，但是客户端只能靠第三方，macos可以用nfs manager, windows未知。服务端参考 [nfs4](https://help.ubuntu.com/community/NFSv4Howto)  
> 下面都是基于NFS3, NFS4太麻烦，不想弄  

1. 分享 zfs dataset: `mnt/share`
```shell
# install nfs
sudo apt install nfs-kernel-server -y
 
# 新增用户
useradd nfsnobody

# 确定用户的gid
id -g nfsnobody

# 确定用户的uid
id -u nfsnobody

# 授权
chown nfsnobody:nfsnobody /mnt/share  
chmod 770 /mnt/share

# anonuid用上面的uid, anongid用上面的gid
sudo zfs set sharenfs='rw,sync,no_root_squash,all_squash,anonuid=0,anongid=0' mnt/share

# 查看分享结果
showmount -e 
```

2. 修改配置文件`/etc/nfs.conf`，取消port的注释，并把它指向一个固定端口    
```editorconfig
[mountd]
port=12222
```
改完后执行nfs重启命令： `systemctl restart nfs-serve`  

3. 设置防火墙（指定内网ip范围，尾段0-255)  
```shell
# 开放nfs默认端口
ufw allow from 192.168.0.0/24 to any port 111
ufw allow from 192.168.0.0/24 to any port 2049

# 开放上面配置文件的端口
ufw allow from 192.168.0.0/24 to any port 12222

# 创建文件
nano /etc/modprobe.d/nlockmgr.conf

# 添加以下内容，然后重启
options lockd nlm_udpport=5000 nlm_tcpport=5000

# 查看端口，找到service: nlockmgr, 记下它的所有端口(5000)
rpcinfo -p

# 开放所有nlockmgr端口
ufw allow from 192.168.0.0/24 to any port 5000
```


# Client

## Windows 11
1. install  
打开powershell(admin)  
```shell
Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
```
2. 关闭nfs  
`nfsadmin client stop`  

3. 修改注册表  
路径： `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default`  
Edit > New > DWORD (32-bit Value) > Name: AnonymousUID  
(right-click on the AnonymousUID) > Modify... > Value data: 0(server 指定uid) > Base: Decimal > OK  
Edit > New > DWORD (32-bit Value) > Name: AnonymousGID  
(right-click on the AnonymousGID) > Modify... > Value data: 0(server 指定gid) > Base: Decimal > OK  

4. 启动nfs  
`nfsadmin client start`  

5. 执行命令 `nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i`  
6. 挂载nfs `mount.exe -o anon \\192.168.1.123\mnt\share X:`  
7. 确认挂载 `mount.exe`  
8. 取消挂载 `umount X:`  
9. 解决乱码： 
Win + R -> intl.cpl -> 管理 -> 更改系统区域设置 -> 勾选使用utf-8 -> 重启  
10. 开机自动挂载：  
任务计划 -> 新建任务 -> 只在用户登录时运行 -> 不勾选使用最高权限 -> 配置:win10  -> 触发器tab -> 新建 -> 开始任务： 登录时 -> 操作tab -> 新建 -> 程序或脚本：mount.exe -> 参数与步骤6保持一致  

## Macos
1. 直接使用`nfs-manager`  
2. 或者手动挂载`sudo mount -t nfs -o resvport,rw 192.168.1.123:/mnt/share /Users/<name>/share`  
3. 开机自动挂载: run step 2 again 😄
