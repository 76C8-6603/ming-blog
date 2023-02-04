---

    title: "ssh root permission denied"
    date: 2019-03-30
    tags: ["linux"]

---

Change `/ect/ssh/sshd_config`  
Add follow row:  
```
PermitRootLogin yes
```
then `service ssh restart`
