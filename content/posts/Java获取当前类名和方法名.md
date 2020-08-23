---
    title: "Java获取当前类名和方法名"
    date: 2018-01-08 
    tags: ["java"]
    
---

### Description
Below I present you two different ways to get the current Class:

* Using Thread
* Using getClass()  

The simplest way to get the name of the class where your code is being executed in is using the getClass() method present in every java object. Like here:

```java
String clazz = this.getClass().getName();
```
This works only if executed in an Object, namely an instanciated class. If you try to execute the code above in a static method. It won't work. Even the keyword this is meaningless in a static method.

Also, the class returned by the above method may actually be a subclass of the class in which the method is defined. This is because subclasses inherit the methods of their parents; and getClass() returns the actual runtime type of the object. To get the actual class in which a method is defined, use the method below also.

In a static method you can instead use the following:

```java
String clazz = Thread.currentThread().getStackTrace()[1].getClassName();
```
Which uses the static methodgetStackTrace() to get the whole stacktrace. This method returns an array, where the first element (index 0) is the getStackTrace() you called and the second element (index 1) is the method your code is in.

A similar trick can be used to find out the name of the method currently executed:

```java
String method = Thread.currentThread().getStackTrace()[1].getMethodName();
```
It's exactly the same principle, just you dig out the name of the method instead of the class.

### The code
```java
package org.wikijava.reflection;  
public class MethodName {  
    public static void main(String[] args) { 
        MethodName methodName = new MethodName();   
        String clazz = Thread.currentThread() .getStackTrace() [1].getClassName();
        String method = Thread.currentThread() .getStackTrace()[1].getMethodName();
        System.out.println("class name: " + clazz + " Method Name " + method); 
        methodName.anotherMethod(); 
    }   
    private void anotherMethod() { 
        String clazz = this.getClass().getName(); 
        String method = Thread.currentThread() .getStackTrace()[1].getMethodName(); 
        System.out.println("class name: " + clazz + " Method Name " + method);   
    }   
}   
```         