---
    title: "Spring @Transactional事务失效"
    date: 2018-05-06
    tags: ["spring"]
    
---

### 问题代码
service方法抛出了异常，但是没有rollback
```java
    @Transactional
    public void batchInsert() throws CommonException{}
```
抛出的自定义异常继承于Exception
```java
public class CommonException extends Exception{}
```
### 问题原因
@Transactional注解默认不能捕获checked异常  
    
    checked异常就是继承于Exception的异常，编辑器强制捕获或者抛出
    unchecked异常就是继承于RuntimeException的异常，编译器不强制处理

### 解决方案
1. 把CommonException改为继承RuntimeException
2. 设置@Transactional(rollbackFor=CommonException.class)

### 发散
除了因为Exception类型原因导致的事务失败，还有可能因为以下原因：
1. @Transactional修饰的方法不是public
2. 本类中没有注解的方法调用有注解的方法
3. 设置的引擎不支持事务
   

