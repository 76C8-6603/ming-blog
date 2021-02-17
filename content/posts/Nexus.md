---

    title: "nexus简介"
    date: 2019-07-13
    tags: ["nexus","maven"]

---
# 简介
Nexus repository Manager可以作为Maven的私服，意味着在Maven中央仓库和你本地项目之间多了一层代理。在本地访问已经加载过的jar包时，私服不需要再重新从中央仓库下载，直接内网传输给本地项目。如果私服中没有，再从中央仓库中下载。此外，因为是私服，你可以直接使用mvn deploy命令，将本地包推到私服中，便于复用和版本管理。  

> 下载和文档参考[nexus oss doc](https://help.sonatype.com/repomanager3)

# maven deploy
maven deploy命令是将本地项目生成的jar包推送到远程仓库，这里可以通过pom.xml中的`<distributionManagement >`将远程仓库配置为nexus  
> 参考[maven distributionManagement](https://maven.apache.org/pom.html#Distribution_Management)