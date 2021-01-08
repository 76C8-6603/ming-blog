---

    title: "Java方法的默认参数"
    date: 2017-05-20
    tags: ["java"]

---
# Java方法如何编译
```java
int add12and13() {
    return addTwo(12, 13);
}
```
将会编译为：
```java
Method int add12and13()
0   aload_0             // Push local variable 0 (this)
1   bipush 12           // Push int constant 12
3   bipush 13           // Push int constant 13
5   invokevirtual #4    // Method Example.addtwo(II)I
8   ireturn             // Return int on top of operand stack;
                        // it is the int result of addTwo()
```
> 引用自官方文档[invoking method](https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-3.html#jvms-3.7)  

注意第一步会默认压入一个this参数，这个this参数可以选择申明或者隐藏  
也就是说`addTwo`有两种声明方法，并且两种都不会影响`addTwo(12,13)`的调用：  
```java
public class Test{
    public int addTwo(int a,int b){
        return a + b;
    }

    public int addTwo(Test this,int a,int b){
        return a + b;
    }
}
```
注意第二种写法，this必须是第一个参数并且不能修改参数名和类型  

那也就可以理解为什么一个参数的方法，可以包装为两个参数的BiFunction：

```java
import java.util.function.BiFunction;

public class User {
    public String test(String msg) {
        System.out.println(msg);
    }
}

public class UnitTest {
    @Test
    public void test1() {
        //第一个User参数，代表了默认的this
        BiFunction<User, String, String> test = User::test;
    }
}
```
