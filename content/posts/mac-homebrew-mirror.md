---

    title: "Mac homebrew 安装设置仓库镜像"
    date: 2021-05-21
    tags: ["mac"]

---

### 仓库镜像
镜像仓库使用的是清华的，具体可参考[hombrew 清华镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)  

安装步骤也可参照上面的地址，唯一有一个地方需要注意，可能出现以下异常：  
```log
Error: Fetching /usr/local/Homebrew/Library/Taps/homebrew/homebrew-services failed!
```
这是权限问题导致，可执行以下命令后，再重新安装  
```shell
sudo chown -R $(whoami) $(brew --prefix)/*
```

### 本体镜像
除了仓库还有`Homebrew-bottles`可能影响下载速度  
该镜像是 Homebrew 二进制预编译包的镜像  

[homebrew-bottles_清华镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew-bottles/)

### 命令参考

homebrew官方的安装和卸载命令可参考[hombrew offical install/uninstall scripts](https://github.com/homebrew/install#uninstall-homebrew)