---
    title: "Git常用命令备忘"
    date: 2018-05-06
    tags: ["git"]
    
---

```shell script
#查看工作区状态
git status -s

#撤回上一次的commit内容
git reset --hard HEAD~

#删除所有本地未提交内容
git checkout .

#下次push时保存输入密码
git config credential.helper store
```
