---
    title: "Git上传本地项目"
    date: 2020-08-23
    tags: ["git"]
    
---

## 1.在git上创建仓库，记下clone地址

## 2.把线上仓库拉到本地
```shell script
git clone https://github.com/*/*.git
```

## 3.把要上传的本地项目文件全部放入本地仓库中

## 4.把所有文件提交到线上
```shell script
git add .
git commit -m "first commit"
git push -u origin master
```