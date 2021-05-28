---

    title: "Mac idea启动项目缓慢"
    date: 2021-05-28
    tags: ["mac","idea"]

---

# 问题原因
解析机器名称耗费时间过长
> 参考[idea issue](https://youtrack.jetbrains.com/issue/IDEA-161967)  

# 解决方案
hosts中添加机器名称
```
127.0.0.1    localhost    <my_computer_name>.local
```
其中`<my_computer_name>`是`hostname`指令结果
