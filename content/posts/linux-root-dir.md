---

    title: "恢复root目录"
    date: 2019-05-12
    tags: ["linux"]

---
误删了/root目录，导致`cd ~`一直报文件夹找不到  
执行一下命令重建  
```shell
mkdir /root
chmod 700 /root
cp -a /etc/skel/.[!.]* /root
```