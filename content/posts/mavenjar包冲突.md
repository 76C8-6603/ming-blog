---
    title: "Maven jar包冲突导致NoClassDefFoundError"
    date: 2019-07-06
    tags: ["maven"]
    
---

### 问题背景
项目的两个依赖，包含了同一个路径，然而因为项目原因还不能删除其中任何一个  
代码在本地和线上都能正常通过编译  
但是一执行到对应代码就会抛出如下error:  
```
    java.lang.NoClassDefFoundError:
```

### 问题原因
    跟踪代码后得知，报错代码引用的是pom中的第二个依赖
    引用位置低于第一个
    然而maven的逻辑是谁的<dependency>在前，就优先选择哪个依赖

### 解决方案
    调整<dependency>的顺序，得以解决