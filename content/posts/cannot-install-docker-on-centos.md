---

    title: "不能在centos7上安装docker"
    date: 2021-03-13
    tags: ["docker"]

---
### 错误信息
```
错误：软件包：docker-ce-rootless-extras-20.10.8-3.el7.x86_64 (docker-ce-stable)
          需要：slirp4netns >= 0.4
错误：软件包：3:docker-ce-20.10.8-3.el7.x86_64 (docker-ce-stable)
          需要：container-selinux >= 2:2.74
错误：软件包：containerd.io-1.4.9-3.1.el7.x86_64 (docker-ce-stable)
          需要：container-selinux >= 2:2.74
错误：软件包：docker-ce-rootless-extras-20.10.8-3.el7.x86_64 (docker-ce-stable)
          需要：fuse-overlayfs >= 0.7
```

### 解决方案
修改文件`/etc/yum.repos.d/docker-ce.repo`，在文件顶部加上以下内容：  
```
[centos-extras]
name=Centos extras - $basearch
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=0
```
然后执行
```shell
yum -y install slirp4netns fuse-overlayfs container-selinux
```

> 参考[https://stackoverflow.com/questions/65878769/cannot-install-docker-in-a-rhel-server](https://stackoverflow.com/questions/65878769/cannot-install-docker-in-a-rhel-server)