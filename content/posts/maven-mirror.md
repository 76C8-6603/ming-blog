---

    title: "maven仓库镜像"
    date: 2017-03-15
    tags: ["maven"]

---

修改`settings.xml`，idea在配置里面搜索maven确定配置文件路径  

```xml
<mirror>
  <id>aliyunmaven</id>
  <mirrorOf>*</mirrorOf>
  <name>阿里云公共仓库</name>
  <url>https://maven.aliyun.com/repository/public</url>
</mirror>
```

> [阿里maven mirror](https://developer.aliyun.com/mvn/guide)