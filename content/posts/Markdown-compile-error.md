---

    title: "Maven compile异常 Failed to execute goal maven-resources-plugin:3.2.0:resources  Input length = 1 "
    date: 2019-03-09
    tags: ["maven"]

---

# 原因
编码问题，可能是`application.properties`和类似的属性文件中有非UTF-8字符（参考[spring-boot-issue](https://github.com/spring-projects/spring-boot/issues/24346) ）  
或者某个依赖包有问题，没有按照utf-8来构建  

# 方案