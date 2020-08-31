---
    title: "观察者模式和java委托"
    date: 2018-01-08 
    tags: ["design pattern"]

---


* 所谓观察者模式，指的某个状态信息的改变，会影响其他一系列的操作，这时就可以将这些操作抽象化，同时创建一个类统一的管理和执行这些操作。把这些抽象出来的操作称为观察者类，而管理这些操作的类称为通知者类，通知者类维护着一个观察者类的集合，可以追加和删除观察者，同时可遍历通知所有观察者类执行操作。
　　　　　

![观察者模式.jpg](/观察者模式.png)

* 观察者模式的不足：虽然观察者模式提取出了抽象类，让类与类之间不互相依赖，共同依赖于抽象接口，这符合依赖倒转原则，但他们仍然依赖着抽象接口，而且有些时候不能提取出抽象的观察者（比如引用jar包）。
* java委托机制与观察者模式：委托机制的实现不再需要提取观察者抽象类，观察者和通知者互不依赖。java利用反射即可实现，代码实例如下:

事件类
```java
package com.suski.delegate;

import java.lang.reflect.Method;

public class Event {
    private Object object;
    
    private String methodName;
    
    private Object[] params;
    
    private Class[] paramTypes;
    
    public Event(Object object,String method,Object...args)
    {
        this.object = object;
        this.methodName = method;
        this.params = args;
        contractParamTypes(this.params);
    }
    
    private void contractParamTypes(Object[] params)
    {
        this.paramTypes = new Class[params.length];
        for (int i=0;i<params.length;i++)
        {
            this.paramTypes[i] = params[i].getClass();
        }
    }

    public void invoke() throws Exception
    {
        Method method = object.getClass().getMethod(this.methodName, this.paramTypes);//判断是否存在这个函数
        if (null == method)
        {
            return;
        }
        method.invoke(this.object, this.params);//利用反射机制调用函数
    }
}
```
事件管理类

```java
package com.suski.delegate;

import java.util.ArrayList;
import java.util.List;

public class EventHandler {

    private List<Event> objects;
    
    public EventHandler()
    {
        objects = new ArrayList<Event>();
    }
    
    public void addEvent(Object object, String methodName, Object...args)
    {
        objects.add(new Event(object, methodName, args));
    }
    
    public void notifyX() throws Exception
    {
        for (Event event : objects)
        {
            event.invoke();
        }
    }
}
```
通知者抽象类

```java
package com.suski.delegate;

public abstract class Notifier {
    private EventHandler eventHandler = new EventHandler();
    
    public EventHandler getEventHandler()
    {
        return eventHandler;
    }
    
    public void setEventHandler(EventHandler eventHandler)
    {
        this.eventHandler = eventHandler;
    }
    
    public abstract void addListener(Object object,String methodName, Object...args);
    
    public abstract void notifyX();

}
```
通知者具体实现类

```java
package com.suski.delegate;

public class ConcreteNotifier extends Notifier{

    @Override
    public void addListener(Object object, String methodName, Object... args) {
        this.getEventHandler().addEvent(object, methodName, args);
    }

    @Override
    public void notifyX() {
        try {
            this.getEventHandler().notifyX();
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
        }
    }
}
```
具体的观察者类，不再需要抽象观察者

```java
package com.suski.delegate;

import java.util.Date;

public class WatchingTVListener {

    public WatchingTVListener()
    {
        System.out.println("watching TV");
    }
    
    public void stopWatchingTV(Date date) 
    {
        System.out.println("stop watching" + date);
    }
}
```

```java
package com.suski.delegate;

import java.util.Date;

public class PlayingGameListener {
    public PlayingGameListener()
    {
        System.out.println("playing");
    }
    
    public void stopPlayingGame(Date date)
    {
        System.out.println("stop playing" + date);
    }
}
```
测试方法

```java
package com.suski.delegate;

import java.util.Date;

public class Test {
    
    public static void main (String[] args)
    {
        Notifier goodNotifier = new ConcreteNotifier();
        
        PlayingGameListener playingGameListener = new PlayingGameListener();
        
        WatchingTVListener watchingTVListener = new WatchingTVListener();
        
        goodNotifier.addListener(playingGameListener, "stopPlayingGame", new Date());
        
        goodNotifier.addListener(watchingTVListener, "stopWatchingTV", new Date());
        
        goodNotifier.notifyX();
    }

}
```
