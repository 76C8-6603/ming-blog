---
    title: "Spring boot 文件路径读取异常"
    date: 2018-08-21 
    tags: ["spring"]
    
---

在开发代码中，有一段需要获取resources目录下的一个配置文件（这里写作test.xml）。

这段代码在ide中没有任何问题，但是一打成jar包发布到线上，这段代码就会报找不到对应文件的错误。

 

按照一般的思路，因为resources目录下的文件经过编译后都会放在classpath根目录下，所以获取到根目录然后追加test.xml即可得到该文件路径。这是尝试获取路径失败的代码：

```java
//直接获取目标文件路径
String filePath = this.getClass.getClassLoader().getResource("text.xml").getPath;

//获取根目录路径1
String rootPath = this.getClass.getClassLoader().getResource("").getPath;

//获取根目录路径2
String rootPath2 = ResourceUtils.getURL("classpath:").getPath();
```
通过以上代码获取到的路径在spring boot项目作为jar包运行时，得到的并不是真实的路径，而是如下的一个路径：

```
workspace/project/target/project.jar!/BOOT-INF/classes!/...
```
 

spring提供了ClassPathResource类处理这种情况，通过ClassPathResource可以直接获取File对象，或者InputStream，这是获取成功的代码：

```java
Resource resource = new ClassPathResource("text.xml");
resource.getFile();
resource.getInputStream();
```