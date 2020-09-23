---
    title: "关于mysql和oracle的大小写敏感"
    date: 2017-05-10
    tags: ["mysql","oracle"]
    
---

## 表名
* `mysql` 每一个表至少对应一个服务器文件，而且名字对应，因此表名的大小写敏感跟系统有关系，windows不区分，linux区分
* `oracle` 所有不在双引号里的内容都会被转为大写，想要区分大小写，就用双引号括起来  

## 字段名
* `mysql` 不区分大小写
* `oracle` 跟表名一样，默认会被转为大写，想要区分，需要双引号

> mysql可以通过修改`lower_case_table_names`属性来忽略表名的大小写区分，参考[Mysql表名忽略大小写](/2017/08/mysql表名忽略大小写/index.html)

**但有个问题需要注意，mysql的大小写忽略，会把所有字符转为小写，而oracle的，像前边所说的会把所有字符转为大写**