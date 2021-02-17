---

    title: "Maven release"
    date: 2017-07-22
    tags: ["maven"]

---

# 简介
Maven release不在maven默认生命周期内，需要通过plugin来实现。Maven release可以自动管理pom.xml中的版本号，以及git tag的版本号。  
常用的命令有以下几个：
* `mvn release:clean`删除由mvn release:prepare生成的所有文件
* `mvn release:prepare`它会运行`mvn clean verify`命令生成jar包，并且会往git上提交并push当前版本tag，同时为当前版本的代码创建分支，然后修改pom中的版本号（默认叠加1，可以手动指定），最后commit对pom.xml的修改（可以通过`mvn release:rollback`命令回滚prepare的修改（包括git提交），但是提交的tag无法回滚）。  
* `mvn release:perform`它会将prepare创建的版本分支代码拉倒本地，并执行`mvn deploy`命令，相当于完整的maven默认生命周期流程。  
> 参考[Maven Release Plugin](http://maven.apache.org/maven-release/maven-release-plugin/index.html)

# 运行要求
要运行release相关命令，首先需要配置pom.xml
```xml
<project>
  ...
  <scm>
    <developerConnection>scm:git:https://github.com/..../....</developerConnection>
  </scm>
  
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-release-plugin</artifactId>
        <version>3.0.0-M1</version>
      </plugin>
    </plugins>
    ...
  </build>
  ...
</project>
```
<scm>和<plugin>是必不可少的  
<scm>中的<developerConnection>指向的就是git的项目地址，最后不加`.git`  

## git认证
除了上面两个必要标签，还需要注意的是访问git的配置信息  
对于maven来说，并不知道你的git用户名密码所以需要在`settings.xml`中新增  
```xml
<servers>
        <server>
            <id>git</id>
            <username>*******@outlook.com</username>
            <password>{wb83456gfhgV71sdfewrvx453EJt4iOVlQ=}</password>
        </server>
</servers>
```
其中id是`pom.xml`用来匹配对应服务的，需要在`pom.xml`中配置该id：  
```xml
<properties>
        <project.scm.id>git</project.scm.id>
</properties>
```

## 密码加密
此外之前settings.xml中的<server><password>是加密的，没有明文密码。获取加密密码还需要更多配置：  
1. 需要执行`mvn --encrypt-master-password`命令，获得master密码
2. 然后将master密码保存到`${user.home}/.m2/settings-security.xml`文件中，只需要以下结构：  
```xml
<settingsSecurity>
  <master>{jSMOWnoPFgsHVpMvz5VrIt5kRbzGpI8u+9EF1iFQyJQ=}</master>
</settingsSecurity>
```
3. 执行`mvn --encrypt-password`命令，按照提示输入你的git密码以获取密文。  

> 更多关于Maven密码加密，参考[Maven Password Encrypt](http://maven.apache.org/guides/mini/guide-encryption.html#Tips)

## <distributionManagement>
由于`mvn release:perform`内部执行了`mvn deploy`命令，因此想要`mvn release:perform`正常运行，必须在`pom.xml`中配置`<distributionManagement>`    
> 参考[maven distributionManagement](https://maven.apache.org/pom.html#Distribution_Management)  

如果没有计划将生成的jar包分发到仓库管理器上（例如nexus），又想执行perform，那么可以将deploy插件屏蔽掉
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0">
    ...
    <plugins>
        ...
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-deploy-plugin</artifactId>
            <configuration>
                <skip>true</skip>
            </configuration>
        </plugin>
    </plugins>
</project>
```