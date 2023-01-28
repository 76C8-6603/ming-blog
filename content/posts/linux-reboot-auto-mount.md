---

    title: "Linux auto remount after reboot"
    date: 2023-01-28
    tags: ["linux"]

---

edit `/etc/fstab`    
add blow entry(only for ext):    
```
/dev/sdb1 /media/disk2 ext2 defaults 0 2
```
1. `/dev/sdb1` device: /dev location or uuid.  
2. `/media/disk2`  mount point.  
3. `ext2` file system type: get it from `file -s /dev/sdb1` command.  
4. `defaults` options.  
5. `0` dump.  
6. `1` pass num.  

> more detail refer to [ubuntu Fstab](https://help.ubuntu.com/community/Fstab)  
