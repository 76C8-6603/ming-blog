---

    title: "Maven构建项目描述网页"
    date: 2017-11-09
    tags: ["maven"]

---

通过以下命令，即可创建项目描述网页
```shell
mvn site
```

跟网页展示资源相关的目录
```
+- src/
   +- site/
      +- apt/
      |  +- index.apt
      !
      +- markdown/
      |  +- content.md
      |
      +- fml/
      |  +- general.fml
      |  +- faq.fml
      |
      +- xdoc/
      |  +- other.xml
      |
      +- site.xml
```
`site.xml`是描述文件，可以指定网页的菜单，链接，和图片等。  
`src/site`下面的每个目录对应一个标记语言，可以选择熟悉的标记语言目录来生成描述信息，但是index文件在所有目录下只能有一个。  
> 详情参考[mvn site](https://maven.apache.org/guides/mini/guide-site.html#github-pages-apache-svnpubsub-gitpubsub-deployment)