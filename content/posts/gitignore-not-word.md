---

    title: "gitignore不生效"
    date: 2018-11-08
    tags: ["git"]

---

# 背景
已经在`.gitignore`中配置，但是被修改的对应文件仍然在changelist中

# 解决方案
到指定目录执行以下命令：  
```shell
# 假如要忽略的文件是 idea.iml
git rm -r --cached idea.iml
```
然后需要再将对应文件提交push一次
