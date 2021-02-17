---
    title: "Java注释引用类和其成员"
    date: 2016-04-05
    tags: ["java"]
    
---

注释中如果要指向一个类或者其成员，直接写名字容易出错，且ide无法跳转。可以使用{@link}来引用
***
```java
/**
* {@link String#toString()} }
* 在类后面追加#号，可以指向类的成员方法或者变量
**/
public class Test{
}
```