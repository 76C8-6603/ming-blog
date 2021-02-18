---

    title: "Maven项目转为Gradle"
    date: 2019-09-22
    tags: ["gradle"]

---
# 执行转换命令
```shell
gradle init
```

# 问题
## idea构建控制台乱码
菜单 `Help->Edit Custom VM Options`  
添加以下VM参数
```
-Dfile.encoding=utf-8
```
## gradle build失败
* idea清除所有失效缓存 `File->invalidate caches/restart`  
* gradle输出目录默认为build跟maven的out有区别，确保`project structure`中配置正确
* maven中如果有依赖lombok，光靠默认init命令生成的lombok依赖是不够的，需要重新配置lombok依赖：  
```
dependencies {
	compileOnly 'org.projectlombok:lombok:1.18.16'
	annotationProcessor 'org.projectlombok:lombok:1.18.16'
	testCompileOnly 'org.projectlombok:lombok:1.18.16'
	testAnnotationProcessor 'org.projectlombok:lombok:1.18.16'
}
```
> 引用自[lombok gradle](https://projectlombok.org/setup/gradle)

