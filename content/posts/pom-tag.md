---

    title: "pom元素说明"
    date: 2017-05-19
    tags: ["maven"]

---

* **project** pom.xml文件的顶级元素  
* **modelVersion** POM使用的对象模型版本。这个模型的版本几乎不更新，作为必要元素的原因是确保稳定性。  
* **groupId** 这个元素代表创建这个项目的机构或者团队的唯一标识符。作为项目的关键标识符，通常的来源是基于机构的完全限定域名。举个例子`org.apache.maven.plugins`，是为所有Maven plugin设计的groupId。  
* **artifactId** 这个元素代表这个项目创建的首要artifact的唯一基础名称。项目的首要artifact一般来说就是JAR文件。次要的artifact，比如说资源包也使用了artifactId作为最终名称的一部分。一个典型Maven产出的artifact会有这样的格式：<artifactId>-<version>.<extension>（举个例子，myapp-1.0.jar）  
* **version** 这个元素代表项目生成的artifact的版本。Maven在版本管理问题上走了很长的路，你会经常在版本中看见`SNAPSHOT`申明符，他代表项目还在一个开发状态。  
* **name** 这个元素代表项目的展示名称。经常被用于Maven生成的文档中。  
* **url** 这个元素代表项目的网址是可以被访问到的。经常被用于Maven生成的文档中。  
* **properties** 这个元素包含的值，可通过申明的占位符在整个POM中访问。  
* **dependencies** 依赖列表，他是POM的基石。  
* **build** 申明项目目录结构和管理插件。  

> 更多POM元素和说明，参考[POM Reference](https://maven.apache.org/pom.html#dependencies)