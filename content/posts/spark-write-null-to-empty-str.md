---
    title: "spark dataset写csv的时候将null值写为空字符串"
    date: 2020-05-07
    tags: ["spark"]
    
---

用spark写csv的时候碰见一个问题，join后未匹配的单元应该是null，但是spark写出来全部都为""  
```text
F23338994668,F23338994669,F23338995220
12,1,1
1,7,""
13,1,1
6,1,1
16,1,1
```
在之后hive加载的时候，由于该列是数字类型，空字符无法匹配数字字段类型，导致有空串的整行都展示为null
```text
F23338994668,F23338994669,F23338995220
12,1,1
,,,
13,1,1
6,1,1
16,1,1
```
追踪代码发现在未写入之前，sql没有问题，也没有执行na().fill()操作，但在write过后，null就变成了""

解决办法，在sparkDF.write之前追加配置.config("emptyValue","")即可
