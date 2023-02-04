---

    title: "linux XFS filesystem"
    date: 2023-01-29
    tags: ["linux"]

---

Run the following commands, if your disk has been mounted, you need to unmount it first  
```shell
apt install xfsprogs
mkfs.xfs /dev/sdb -L DISK1
```

Add the entry to `/etc/fstab`, then you don't need to mount it again after each reboot:    
```
LABEL=DISK2      /mnt/disk2     xfs     defaults,noatime  0       2
```