---

    title: "Maven 编译跳过单元测试"
    date: 2019-10-11
    tags: ["maven","test"]

---

修改pom.xml  
```xml
<build>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version></version>
        <configuration>
            <skipTests>true</skipTests>
        </configuration>
    </plugin>
</build>
```