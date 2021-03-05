---

    title: "jenkins找不到本地仓库中的jar包"
    date: 2019-10-29
    tags: ["jenkins","maven","git"]

---
# 背景
在`execute shell`中写的命令老是出错，各种权限问题，但是直接在目标文件夹里执行命令又没有问题。

# 原因
主要就是用户权限的问题，切换到jenkins用户操作即可`su - jenkins`  