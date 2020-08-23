---
    title: "Oracle extract函数提取时分秒的问题"
    date: 2020-07-30T17:42:55+08:00
    tags: ["java"]
    
---

当提取字段为Date类型时，extract只能读取年月日，提取时分秒会报错

要提取年月日，需要将Date类型转为timestamp

