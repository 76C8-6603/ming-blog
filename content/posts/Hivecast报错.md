---
    title: "hive cast( as integer)报错 in primitive type specification"
    date: 2020-05-09
    tags: ["hive"]
    
---

原因是hive版本太老，不能识别integer，只能识别int  
[官方说明](http://mail-archives.apache.org/mod_mbox/hive-dev/201310.mbox/%3CJIRA.12595720.1340551511790.3851.1383257119001@arcas%3E)  
生效版本是0.8.0  
![官方说明截图](/hivecast.png)

