---

    title: "包含多个模块的项目如何配置maven"
    date: 2017-11-07
    tags: ["maven"]

---
# 项目结构
```
+- pom.xml
+- my-app
| +- pom.xml
| +- src
|   +- main
|     +- java
+- my-webapp
| +- pom.xml
| +- src
|   +- main
|     +- webapp
```
可以看到该项目下包含两个module:my-app、my-webapp。两个子module都有对应的pom.xml文件。

# pom
最外层的项目pom.xml
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
 
  <groupId>com.mycompany.app</groupId>
  <artifactId>app</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>pom</packaging>
 
  <modules>
    <module>my-app</module>
    <module>my-webapp</module>
  </modules>
</project>
```
上面的`<packaging>`和`<modules>`标签是用来保证每个子模块的pom相关命令都能被执行到  
注意`<module>`标签中的值是子模块的相对路径，如果子模块不是父项目的子文件夹，而是同级的文件夹，那么`<module>`的值就应该是`../my-app`

如果子模块中有依赖，比如`my-webapp`依赖`my-app`，那么需要在my-webapp模块中的pom.xml文件中添加依赖：
```xml
<dependencies>
    <dependency>
      <groupId>com.mycompany.app</groupId>
      <artifactId>my-app</artifactId>
      <version>1.0-SNAPSHOT</version>
    </dependency>
    ...
  </dependencies>
```
上面的子模块依赖，保证my-webapp生成的包中包含了my-app的包，并且my-app的包构建永远在my-webapp之前  

然后两个子模块的pom.xml中分别需要追加一个`<parent>`标签，以防子模块单独构建找不到父模块的依赖：
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <parent>
    <groupId>com.mycompany.app</groupId>
    <artifactId>app</artifactId>
    <version>1.0-SNAPSHOT</version>
  </parent>
  ...
```
如果需要继承父项目的版本号和`groupId`，在子模块中不申明<version>和<groupId>即可

另外，如果子模块要继承的父项目不像上面的结构一样，并且父项目也不在本地仓库中，比如像这样的结构：  
```
.
 |-- my-module
 |   `-- pom.xml
 `-- parent
     `-- pom.xml
```
那么就需要手动指向父模块的`pom.xml`文件：
```xml
<project>
  <modelVersion>4.0.0</modelVersion>
 
  <parent>
    <groupId>com.mycompany.app</groupId>
    <artifactId>my-app</artifactId>
    <version>1</version>
    <relativePath>../parent/pom.xml</relativePath>
  </parent>
 
  <artifactId>my-module</artifactId>
</project>
```
`<relativePath>`标签就是指相对于当前模块，父模块`pom.xml`文件所在的相对位置