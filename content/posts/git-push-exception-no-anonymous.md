---
    title: "Git push 异常：remote: No anonymous write access"
    date: 2018-05-06
    tags: ["git"]
    
---

异常信息

    No anonymous write access. Authentication failed for
    
解决方案
    
    提交的时候设置UserName和email
或者重新设置全局git用户名和邮箱
```shell script
git config --global user.name "username"

git config --global user.email "email"
```

