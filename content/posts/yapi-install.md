---

    title: "yapi安装"
    date: 2020-07-05
    tags: ["yapi"]

---
## Docker部署
[yapi docker install](https://github.com/fjc0k/docker-YApi)


## 手动安装
参照官方文档[yapi install](https://hellosean1025.github.io/yapi/devops/index.html)  
注意提供的可视化部署已不可用，直接通过命令行部署  

部署完成后可通过pm2对yapi进行管理：  
```shell
npm install pm2 -g  //安装pm2
cd  {项目目录}
pm2 start "vendors/server/app.js" --name yapi //pm2管理yapi服务
pm2 info yapi //查看服务信息
pm2 stop yapi //停止服务
pm2 restart yapi //重启服务
```