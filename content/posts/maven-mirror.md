---

    title: "maven仓库镜像"
    date: 2017-03-15
    tags: ["maven"]

---

修改`settings.xml`，idea在配置里面搜索maven确定配置文件路径  

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>aliyunmaven</id>
            <mirrorOf>*</mirrorOf>
            <name>阿里云公共仓库</name>
            <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
    </mirrors>
</settings>
```

> [阿里maven mirror](https://developer.aliyun.com/mvn/guide)  
> [maven official settings overview](https://maven.apache.org/settings.html#Quick_Overview)