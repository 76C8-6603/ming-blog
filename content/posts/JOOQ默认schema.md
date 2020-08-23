---
    title: "JOOQ默认schema"
    date: 2020-07-14T11:16:55+08:00
    tags: ["jooq"]
    
---

Setting中有个选项setRenderSchema(true)，但是这种只适用于表是由JOOQ代码生成器生成的表对象。

如果是自己声明的表对象（DSL.table()），想要让JOOQ在渲染时自己加上schema，稍微麻烦一点。

这里假设需要加上的默认schema为：liuneng
    
```java
Settings settings = new Settings()
                    .withRenderMapping(new RenderMapping()
                    .withSchemata(new MappedSchema().withInput("").withOutput("liuneng")));
```
这样设置后,JOOQ在渲染表名的时候会把未设置schema的表，统一加上liuneng，但是还有一个前提，你的表必须要按照以下方式声明：
```java
DSL.table(name("my_table"))
```