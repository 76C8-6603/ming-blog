---

    title: "h2兼容模式"
    date: 2018-12-15
    tags: ["h2"]

---

h2有多种数据库兼容模式，例如Mysql：`jdbc:h2:mem:testdb;MODE=MYSQL`。  
但是兼容模式并不可靠，还是有部分特有语句会直接报错，比如mysql的collate。因此最好还是直接使用h2原模式，使用标准sql语法。  

> 参考[h2 command](https://www.h2database.com/html/commands.html)