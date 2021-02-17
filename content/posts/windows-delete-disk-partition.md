---
    title: "Windows删除启动盘的所有分区"
    date: 2018-07-08
    tags: ["windows"]
    
---

**win10右键徽标->Windows Powershell(管理员)**

1. `dispark`
2. `list disk` 展示所有磁盘
3. `select disk #` 确认好所选目标磁盘，#号为id
4. `clean` 删除选中磁盘的所有内容
5. `exit`

