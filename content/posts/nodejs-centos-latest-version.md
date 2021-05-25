---

    title: "Centos安装nodejs最新版"
    date: 2021-05-25
    tags: ["nodejs"]
    draft: true

---

```shell
# 安装epel，确保能搜到nodejs
yum install epel-release

# 安装
yum install nodejs

# 查看当前版本，一般都是六点几，官网已经更新到十六点几了
node -v

# 安装npm版本管理工具n
npm install -g n

# 查看最新的版本号
n latest

# 根据最新的版本号，安装指定版本
n 16.2.0

# 执行版本切换命令，根据提示切换版本
n

# 查看最终版本号
node -v
```
前面的流程走完后，可能会出现问题，原因是nodejs和n的安装位置不匹配的原因  
解决方案如下：
```shell
# 查询node的安装位置，这里的位置是 /usr/local/bin/node
which node
# 修改环境变量
vim ~/.bash_profile
```
在`.bash_profile`添加如下内容：
```
export N_PREFIX=/usr/local 
export PATH=$N_PREFIX/bin:$PATH
```
最后让`.bash_profile`生效
```shell
source ~/.bash_profile
```
再执行`node -v`确定版本

