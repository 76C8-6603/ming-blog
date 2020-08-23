---
    title: "SBT仓库镜像配置"
    date: 2020-02-24
    tags: ["scala"]
    
---

# 一、打开sbt安装路径找到conf\sbtconfig.txt，在文件末尾添加仓库文件地址
```properties
-Dsbt.repository.config=%SBT_HOME/sbt/conf/repository.properties
```
# 二、在对应目录创建repository.properties，并添加如下内容
```properties
[repositories]
local
aliyun-nexus: http://maven.aliyun.com/nexus/content/groups/public/  
ibiblio-maven: http://maven.ibiblio.org/maven2/
typesafe-ivy: https://dl.bintray.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
uk-repository: http://uk.maven.org/maven2/
jboss-repository: http://repository.jboss.org/nexus/content/groups/public/
typesafe: http://repo.typesafe.com/typesafe/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
sonatype-oss-releases
maven-central
sonatype-oss-snapshots
```
# 三、同时在~/.sbt(windows在“用户/.sbt”)下创建文件repositories，并添加上面的内容