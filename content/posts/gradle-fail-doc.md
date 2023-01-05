---

    title: "Gradle 中文注释 unmappable character"
    date: 2022-12-20
    tags: ["gradle"]

---

> unmappable character for encoding windows-1252  

解决方法：  
在gradle文件中添加如下内容：  
```properties
javadoc {
    options.encoding = 'UTF-8'
}
```