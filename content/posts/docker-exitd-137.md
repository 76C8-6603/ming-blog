---

    title: "Docker容器启动时自动退出 无报错"
    date: 2021-07-20
    tags: ["docker"]

---

* 首先通过查看容器日志，看是否有明确的报错日志
```shell
docker logs -f elasticsearch
```
在这里，日志是没有任何错误信息的，看起来一切正常，但是容器会在几秒钟后自动退出  

* 日志无法查到有用信息，接下来通过inspect命令，检查容器信息
```shell
docker inspect elasticsearch
```
```json
[
    {
        "Id": "c9c1531b1625fe5700f0d82683cab776e25871eb2007d337dfefa24df19d75b3",
        "Created": "2021-07-20T02:15:12.3387822Z",
        "Path": "/usr/local/bin/docker-entrypoint.sh",
        "Args": [
            "eswrapper"
        ],
        "State": {
            "Status": "exited",
            "Running": false,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 0,
            "ExitCode": 137,
            "Error": "",
            "StartedAt": "2021-07-20T02:34:50.4842533Z",
            "FinishedAt": "2021-07-20T02:34:59.5086676Z"
        },
......
```
上面是inspect展示的部分信息，关注State，可以看到容器并不是因为内存溢出被杀掉的(`OOMKilled = false`)  
这里能获取的信息就是`ExitCode`。通过`ExitCode=137`找到了相关问题：
> [Docker Container exited with code 137](https://www.petefreitag.com/item/848.cfm)  

* 修改docker的内存配置  

总结下上面的文章，就是因为系统为docker分配的内存资源不够，直接触发了系统的Killer，终止了进程。  
通过改变docker的总分配内存修复该问题，在mac上可通过界面修改：  
![mac](/docker-mem-change.png)
