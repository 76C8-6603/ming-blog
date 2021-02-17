---
    title: "Git常用命令备忘"
    date: 2018-05-06
    tags: ["git"]
    
---

```shell script

# git更新当前分支
git pull

#拉线上代码
git clone https://***.git.com

#查看工作区状态
git status -s

#撤回上一次的commit内容
git reset --hard HEAD~

#查看当前分支
git branch

#切换到对应分支
git checkout dev

#删除所有本地未提交内容
git checkout .

#下次push时保存输入密码
git config credential.helper store

#更改当前项目的用户名和邮箱
git config user.name ""
git config user.email ""

#更改全局的用户名和邮箱
git config --global user.name ""
git config --global user.email ""

#git日志
git log

#取消cherry pick
git cherry-pick --abort

#在指定路径添加子模块
git submodule add <url> [path] 

```
