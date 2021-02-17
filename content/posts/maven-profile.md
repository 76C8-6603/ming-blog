---

    title: "maven profile"
    date: 2017-08-11
    tags: ["maven"]

---

# 简介
maven profile插件可以根据环境参数，系统os，文件是否存在，和JDK版本等条件决定是否激活配置。激活的配置可以是环境参数的赋值，对应版本的依赖，部分pom标签的替换或者是整个pom的替换。  
> 详情参考[maven profile](https://maven.apache.org/guides/introduction/introduction-to-profiles.html)  

# 实例
下面的例子是通过profile对不同环境的配置文件进行筛选，首先是文件结构：  
```
-src.main.resources
    -env
        -dev.properties
        -test.properties
        -prod.properties
        
    -application.properties
```

## application.properties
```properties
spring.datasource.username=@datasource.username@
spring.datasource.password=@datasource.password@
```
可以看到文件中只包含了数据库的用户名密码，根据环境的不同，对应的数据库用户名和密码不同。  
这里用了Spring-boot框架，参数的引用需要用@包裹，如果是yml文件，除了@还需要把整个引用用引号括起来，比如：`"@datasource.password@"`  

## env/*.properties
```properties
datasource.username=dev
datasource.password=123
```
env下每个环境对应的properties文件，都对`datasource.username`和`datasource.password`有明确赋值。下一步就是要将这些文件跟环境变量相关联。  

## pom.xml

```xml

<project xmlns="http://maven.apache.org/POM/4.0.0">
    ...
    <profiles>
        <profile>
            <id>dev</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <env>dev</env>
            </properties>
        </profile>
        <profile>
            <id>test</id>
            <properties>
                <env>test</env>
            </properties>
        </profile>
        <profile>
            <id>prod</id>
            <properties>
                <env>prod</env>
            </properties>
        </profile>
    </profiles>
    
    <build>
        <!-- filters用于将环境文件的参数导入到pom中，让pom可以通过${}方式调用文件中的属性 -->
        <filters>
            <filter>src/main/resources/env/${env}.properties</filter>
        </filters>
    </build>
    <!-- resources让指定目录下的属性文件可以通过${}方式访问pom中的属性值(spring boot用@包围) -->
    <resources>
        <resource>
            <directory>src/main/resources</directory>
            <filtering>true</filtering>
            <includes>
                <include>*.properties</include>
            </includes>
        </resource>
    </resources>
</project>
```
上面的配置缺一不可。在profiles中，dev是默认激活的，而其他两个profile没有默认触发条件，只有通过命令行参数直接激活。  

```shell
# 替换测试环境配置
mvn clean verify -Ptest

# 替换生产环境配置
mvn clean verify -Pprod
```

```shell
# 替换测试环境配置
mvn clean verify -Denv=test

# 替换生产环境配置
mvn clean verify -Denv=prod
```
上面两种方式达到的效果是一样的，不过一个是通过profile触发的，另外一个是直接给env变量赋值触发的

