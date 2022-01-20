---

    title: "Maven常用命令备忘"
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

# 项目依赖结构
mvn dependency:tree

# 项目依赖分析
mvn dependency:analyze

# plugin详情，加上-Dgoal可以查看指定goal的详情
mvn release:help -Ddetail -Dgoal=stage

# 安装jar包到本地仓库
mvn install:install-file \
   -Dfile=<path-to-file> \
   -DgroupId=<group-id> \
   -DartifactId=<artifact-id> \
   -Dversion=<version> \
   -Dpackaging=<packaging> \
   -DgeneratePom=true

# 离线打包
mvn -o package

# 指定自定义settings.xml运行命令
mvn -s YourOwnSettings.xml clean install

# 加密密码，用于settings.xml中的服务密码等
mvn --encrypt-password <password>

# 加载资源文件，通常用于检查指定${}是否正常赋值
mvn process-resources

# maven 清理所有仓库和缓存
mvn dependency:purge-local-repository -DactTransitively=false -DreResolve=false

# 查看maven的debug信息，其中包含当前使用的仓库，settings.xml等
mvn -X

mvn deploy:deploy-file \
  -DgroupId=com.cloudera.hive \
  -DartifactId=HiveJDBC41 \
  -Dversion=2.6.5 \
  -Dpackaging=jar \
  -Dfile=./HiveJDBC41.jar \
  -Durl=http://custom-repository.com/repository/maven-releases/ \
  -DrepositoryId=releases
```