---

    title: "Maven命令备忘"
    date: 2017-06-15
    tags: ["maven"]

---
```shell
# 编译项目
mvn compile

# 执行项目中的单元测试
# 查找单元测试类的默认规则：**/*Test.java;**/Test*.java;**/*TestCase.java
# 排除单元测试类的默认规则：**/Abstract*Test.java;**/Abstract*TestCase.java
mvn test

# 编译测试代码但不执行
mvn test-compile

# 生成JAR文件，在${basedir}/target 目录下
mvn package

# 官方默认推荐命令。代表执行集成测试或者一些质量验证，除了对应的当前阶段，还执行了validate，compile，test，package
mvn verify

# 将生成JAR文件安装到本地仓库，本地仓库默认路径：${user.home}/.m2/repository
mvn install

# 生成项目基础信息网站
mvn site

# 删除 target 目录下的所有构建数据
mvn clean

# 根据模板创建maven项目
mvn archetype:generate

# 构建完整依赖，能够独立运行的jar包
mvn clean package

# 运行Spring-boot项目
mvn spring-boot:run

# 删除target目录内容，重新编译测试构建，然后部署到远程共享仓库
mvn clean deploy

# 从本地仓库删除指定jar
mvn dependency:purge-local-repository -DmanualInclude="groupId:artifactId, ..."
```