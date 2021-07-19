---

    title: "Mybatis判断字符串为空"
    date: 2018-04-06
    tags: ["mybatis"]

---

* 第一种方法
```xml
<if test="userName != null && userName.trim().length !=0 " > 
```

* 第二种方法
```xml
<if test="@org.apache.commons.StringUtils@isEmpty(userName)" >
```