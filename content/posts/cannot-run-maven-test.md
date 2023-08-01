---

    title: "maven test不能运行"
    date: 2021-05-17
    tags: ["maven","test"]

---

执行mvn test的时候没有任何结果，也不执行对应测试类，如下
```log
-------------------------------------------------------
 T E S T S
-------------------------------------------------------

Results :

Tests run: 0, Failures: 0, Errors: 0, Skipped: 0

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  8.044 s
[INFO] Finished at: 2021-05-17T14:39:39+08:00
[INFO] ------------------------------------------------------------------------

Process finished with exit code 0
```

原因是Maven surefire版本的问题，Junit5需要2.22.0版本及以上（目前还没找到官方文档说明，之后再补）只需要调整一下surefire插件的版本：
```xml
 <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <!-- JUnit 5 requires Surefire version 2.22.0 or higher -->
    <version>2.22.0</version>
</plugin>
```