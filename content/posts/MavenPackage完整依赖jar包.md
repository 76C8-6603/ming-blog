---
    title: "Maven package完整依赖jar包"
    date: 2018-07-15
    tags: ["maven"]
    
---

maven package生成的jar包默认是没有项目依赖的    
需要导出的jar包包含项目所有的依赖，需要配置pom：
```xml
<build>
        <finalName>yourApp</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <configuration>
                    <shadedArtifactAttached>true</shadedArtifactAttached>
                    <shadedClassifierName>jar-with-dependencies</shadedClassifierName> <!-- Any name that makes sense -->
                    <outputDirectory>../output/jar-with-dependencies</outputDirectory>
                </configuration>
            </plugin>
        </plugins>
</build>
```
注意以上配置之后，maven还是会生成一个无依赖的jar包，但是在你设置的`<outputDirectory>`路径下会有一个全依赖的jar包