---
    title: "SparkSession.read().csv()无法定位本地文件的问题"
    date: 2019-09-18
    tags: ["spark"]
    
---

原因是spark有两个文件头

　　\[file://]代表本地

　　\[hdfs://]代表hdfs路径

如果路径没有文件头，spark会将该路径默认添加上"hdfs://"

所以如果要访问本地csv文件，需要确保路径前面有"file://"

```java
//java代码，告诉spark这是本地文件
"file:///" + url
```