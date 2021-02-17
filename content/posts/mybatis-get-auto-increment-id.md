---
    title: "Mybatis insert完成后获取自增主键"
    date: 2016-05-20
    tags: ["mybatis"]
    
---

### 示例代码
```java
public void insert(User user){
    mapper.insert(user);
    String id = user.getId();
}
```
id会赋值到传进来的user对象中

### xml
```xml
<insert keyProperty="id" keyColumn="id" useGeneratedKeys="true">
    INSERT INTO ...
</insert>
```
keyProperty代表实体类中主键对应的成员变量名称  
keyColumn代表表主键字段对应的名称  
userGeneratedKeys代表使用的是自增id