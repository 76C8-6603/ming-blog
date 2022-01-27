---

    title: "Java解析parquet文件"
    date: 2022-01-27
    tags: ["parquet"]

---
Apache提供的parquet解析工具，对hadoop包依赖较大，目前无法做到完全独立  
具体方法可以参考[idea parquet plugin](https://github.com/benwatson528/intellij-avro-parquet-plugin) 源码  

> 该项目是一个[IDEA的插件](https://plugins.jetbrains.com/plugin/12281-avro-and-parquet-viewer) ，主要用于avro和parquet文件的解析预览  

项目最小化了parquet对hadoop的依赖，优化了官方工具对本地文件的支持
