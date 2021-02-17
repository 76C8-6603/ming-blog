---

    title: "java lambda表达式map和flatMap"
    date: 2017-09-23
    tags: ["java"]

---

# 资源类
`User`
```java
@Data
public User{
    private String name;
    private List<String> tags;
}
```

# map&flatmap
`map`将每个参数对象映射为返回类型，一个参数对应一个返回值
```java
List<User> userList = new ArrayList<User>();
//...省略赋值
List<String> userNames = userList.stream().map(user -> user.getName()).collect(Collectors.toList());
```  

`flatMap`将每个参数对象映射为返回类型，一个参数对应多个返回值
```java
List<User> userList = new ArrayList<User>();
//...省略赋值
Set<String> allUserTags = userList.stream().flatMap(user -> user.getTags().stream()).collect(Collectors.toSet());
```

`map`和`flatMap`返回的都是一个`Stream`，不过一个`Stream`里面只有一个值，另一个`Stream`可能包含多个

