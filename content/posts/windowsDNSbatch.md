---
    title: "Windows IP DNS批处理"
    date: 2018-03-22 
    tags: ["windows"]
    
---
指定ip信息，只需要修改set参数  
name是`控制面板\网络和 Internet\网络连接`中对应的连接名称
```shell script
@echo off
set name="Wi-Fi"
set ipaddress=172.16.61.216
set mask=255.255.255.0
set gateway=172.16.61.254
set dns1=172.16.3.38
set dns2=172.16.3.41
netsh interface ip set address name=%name% source=static addr=%ipaddress% mask=%mask% gateway=%gateway% 1
netsh interface ip set dns name=%name% source=static addr=%dns1% register=PRIMARY
netsh interface ip add dns name=%name% addr=%dns2% index=2
```
恢复默认ip配置
```shell script
@echo off
set name="Wi-Fi"
netsh interface ip set address name=%name% source=dhcp
netsh interface ip set dns name=%name% source=dhcp
```