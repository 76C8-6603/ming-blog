---
    title: "Maven如何正确导入本地包，保证在线上正常运行"
    date: 2019-06-06
    tags: ["maven"]
    
---
## 方法一：直接通过命令导入本地包
```shell
mvn install:install-file -Dfile=your-artifact-1.0.jar \
                         [-DpomFile=your-pom.xml] \
                         [-Dsources=src.jar] \
                         [-Djavadoc=apidocs.jar] \
                         [-DgroupId=org.some.group] \
                         [-DartifactId=your-artifact] \
                         [-Dversion=1.0] \
                         [-Dpackaging=jar] \
                         [-Dclassifier=sources] \
                         [-DgeneratePom=true] \
                         [-DcreateChecksum=true]
```

## 方法二：通过plugin导入本地包

### pom设置
```xml
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-install-plugin</artifactId>
        <version>2.5.1</version>
        <executions>
            <execution>
                <id>install-jar-lib</id>
                <goals>
                    <goal>install-file</goal>
                </goals>
                <!--在mvn package的时候将jar包追加到本地仓库，可修改为validate，以线上容器编译执行的mvn命令为准-->
                <phase> process-resources</phase>
                <configuration>
                    <groupId>custom</groupId>
                    <artifactId>custom</artifactId>
                    <version>1.0</version>
                    <packaging>jar</packaging>
                    <file>${project.basedir}/src/main/resources/lib/custom.jar</file>
                    <generatePom>true</generatePom>
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```

然后加上依赖
```xml
<dependency>
    <groupId>custom</groupId>
    <artifactId>custom</artifactId>
    <version>1.0</version>
    <systemPath>${project.basedir}/src/main/resources/lib/custom.jar</systemPath>
    <scope>system</scope>
</dependency>
```

### 可能遇到的问题
1. 本地编译不通过
```
   本地环境执行一下mvn process-resources(对应pom填写的<phase>)
```
2. 线上编译不通过
```
   检查<phase>中的mvn语句
```
3. 本地和线上环境编译都通过，但是执行到对应代码就报错，提示找不到类
```
   确保<dependency>正确填写，如果有多个module使用，<plugin>可以只写一次，但是每个module都要填写对应<dependency>
   如果导入的本地包与现有包冲突也会出现这种问题，如果以本地包为准，需要保证本地包的<dependency>在文本顺序上要先于已有的包
```

