---

    title: "Mac终端代理配置"
    date: 2021-05-15
    tags: ["linux","mac"]

---
# 1. 默认命令配置
```shell
vi ~/.bash_profile
```

加入如下内容
```
# proxy
alias proxy='export all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset all_proxy'
```

执行以下命令生效
```shell
source ~/.bash_profile
```

# 2. zsh命令配置
```shell
vi ~/.zshrc
```

加入如下内容
```
# proxy
alias proxy='export all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset all_proxy'
```

执行以下命令生效
```shell
source ~/.zshrc
```

# 3. 运行命令
启用代理
```shell
proxy
```

弃用代理
```shell
unproxy
```

查询代理的执行情况
```shell
curl ipinfo.io
```