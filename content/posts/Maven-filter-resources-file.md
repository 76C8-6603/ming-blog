---

    title: "如何在资源文件中读取Maven相关的参数"
    date: 2017-10-12
    tags: ["maven"]

---

# pom resources
首先要为pom文件新添一个`resources`标签
```xml
<project>
    <name>...</name>
    <groupId>...</groupId>
    <version>...</version>
    ...
    
    <build>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
            </resource>
            <filtering>true</filtering>
        </resources>
    </build>
</project>
```
默认情况下`<filtering>`的属性为false，因此需要申明来覆盖它。resource的`directory`标签申明了资源的路径，代表该路径下的资源都可以通过`@property@`（注意是被@包裹）的方式来访问以下相关的属性：
* pom中的属性，例如：`@project.name@` `@project.version@` `@project.build.finalName@`
* settings.xml中的属性，例如：`@settings.localRepository@`
* 系统属性，例如： `@java.version@` `@user.home@`  


```properties
#application.properties
application.name=@project.name@
application.version=@project.version@
java.version=@java.version@
```
以上的属性引用，都会在`mvn build`阶段通过`mvn process-resources`语句处理为实际的值。手动执行完`mvn process-resources`命令，在`target/classes`下的资源就会变成这样：  
```properties
#application.properties
application.name=test
application.version=1.1
java.version=1.8
```

除了系统中已经定义好的属性，你还可以自定义属性

# 外部文件属性
定义一个外部属性文件`src/main/filters/filter.properties`：
```properties
# filter.properties
my.filter.value=hello!
```
要访问这个属性文件，需要更改pom文件`build`块的内容：
```xml
<build>
    <filters>
      <filter>src/main/filters/filter.properties</filter>
    </filters>
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>
  </build>
```
相比之前的build，增加了一个`filters`标签，将自定义属性文件的路径作为子标签的属性。这样在src/main/resources路径下的资源文件中就可以直接访问了：
```properties
#application.properties
application.name=@project.name@
application.version=@project.version@
java.version=@java.version@
my.filter.value=@my.filter.value@
```

# pom properties
pom文件中的properties属性，不仅在pom文件中能调用，在外部资源文件中也能像前面那样调用。
```xml
<project>
    <name>...</name>
    <groupId>...</groupId>
    <version>...</version>
    ...
    
    <properties>
        <my.property>myProperty</my.property>
    </properties>
    
    <build>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
            </resource>
            <filtering>true</filtering>
        </resources>
    </build>
</project>
```
```properties
#application.properties
application.name=@project.name@
application.version=@project.version@
java.version=@java.version@
my.filter.value=@my.filter.value@
my.property=@my.property@
```

# 命令行属性
跟在mvn后面的属性参数，也能在`src/main/resources`目录中的资源文件中调用：
```shell
mvn package "-Dmy.command.property=commandProperty"
```
规则就是在`-D`后边加上属性键值对(key=value)

```properties
#application.properties
application.name=@project.name@
application.version=@project.version@
java.version=@java.version@
my.filter.value=@my.filter.value@
my.property=@my.property@
my.command.property=@my.command.property@
```

