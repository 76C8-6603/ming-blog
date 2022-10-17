---

    title: "Swift 常用命令"
    date: 2022-08-25
    tags: ["swift"]

---

```shell

# swift interactive shell
swift repl

# init a package (create manifest file for current package)
swift package init

# init a executable package
swift package init --type executable

# build a package
swift build

# run the tests for package
swift test  

# build and run executable package
swift run Hello <param>  

# 编译指定swift，生成可执行文件，并生成debug信息
swiftc -g Factorial.swift  

# 进入debug交互窗口
lldb Factorial

# 在第几行打断点
(lldb)b 2

# 运行
(lldb)r

# inspect value of param(swift expression support: p n*n)
(lldb)p n

# 查看断点调用链路
(lldb)bt

# continue
(lldb)c

# disable all breakpoints
(lldb)br di
```