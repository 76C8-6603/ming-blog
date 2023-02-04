---

    title: "ZFS"
    date: 2023-02-02
    tags: ["linux"]

---

# Install  

```shell
# install  
sudo apt-get install zfsutils-linux -y
# get disk names
lsblk
# create pool
zpool create storage-pool raidz1 xvdf xvdg -f
```

# Others
```shell
# check all pools or specify a pool/dataset
zfs list <pool/disk>

# check the pool status, you can specify a pool name.
zpool status <pool>

# 下线指定硬盘
zpool offline [pool name] [disk name from zpool status]

# 替换下线硬盘
sudo zpool replace [pool name] [disk name from zpool status] [new disk name]

# 创建一个dataset, 有很多参数可选，参考 https://docs.oracle.com/cd/E19253-01/819-5461/gazss/index.html
zfs create [pool]/[dataset]

# 获取dataset的配置，all可以改为指定配置名
zfs get all rpool/data1

# 创建完成后修改dataset的配置
zfs set compression=gzip-5 rpool/data1

# 分享nfs(默认version 3)，anonuid和anongid分别是指定用户的uid和gid，在client端需要用到
sudo zfs set sharenfs='rw,sync,no_root_squash,all_squash,anonuid=0,anongid=0' /mnt/share

# 取消分享（貌似没吊用）
zfs set sharesmb=off /mnt/share

```