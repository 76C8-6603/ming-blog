---

    title: "原型模式"
    date: 2017-01-07
    tags: ["design pattern"]

---

# 简介
> 用原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。[DP]  

原型模式要表达的意思就是克隆。当多个对象只有个别属性值不一样时，这时new出每个对象，再对每个属性赋值，显然是不合适的。  
这时原型模式就是很好的解决方式，只new一个对象，对公共属性赋值完成后，直接克隆即可。  
# 类图
![Prototype_UML.svg.png](/Prototype_UML.svg.png)
# 代码
```java
/** Prototype Class **/
 public class Cookie implements Cloneable {
   
    public Object clone() throws CloneNotSupportedException
    {
        //In an actual implementation of this pattern you would now attach references to
        //the expensive to produce parts from the copies that are held inside the prototype.
        return (Cookie) super.clone();
    }
 }
 
 /** Concrete Prototypes to clone **/
 public class CoconutCookie extends Cookie { }
 
 /** Client Class**/
 public class CookieMachine
 {
 
   private Cookie cookie;//cookie必须是可复制的
 
     public CookieMachine(Cookie cookie) { 
         this.cookie = cookie; 
     } 

    public Cookie makeCookie()
    {
        try
        {
            return (Cookie) cookie.clone();
        } catch (CloneNotSupportedException e)
        {
            e.printStackTrace();
        }
        return null;
    } 

 
     public static void main(String args[]){ 
         Cookie tempCookie =  null; 
         Cookie prot = new CoconutCookie(); 
         CookieMachine cm = new CookieMachine(prot); //设置原型
         for(int i=0; i<100; i++) 
             tempCookie = cm.makeCookie();//通过复制原型返回多个cookie 
     } 
 }
```