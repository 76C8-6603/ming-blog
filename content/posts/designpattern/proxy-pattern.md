---

    title: "代理模式"
    date: 2017-01-07
    tags: ["design pattern"]

---

# 简介
> 为其他对象提供一种代理以控制对这个对象的访问。  

# 类图
![Proxy_pattern_diagram.svg.png](Proxy_pattern_diagram.svg.png)

```java
import java.util.*;
 
interface Image {
    public void displayImage();
}

//on System A 
class RealImage implements Image {
    private String filename;
    public RealImage(String filename) { 
        this.filename = filename;
        loadImageFromDisk();
    }

    private void loadImageFromDisk() {
        System.out.println("Loading   " + filename);
    }

    public void displayImage() { 
        System.out.println("Displaying " + filename); 
    }
}

//on System B 
class ProxyImage implements Image {
    private String filename;
    private Image image;
 
    public ProxyImage(String filename) { 
        this.filename = filename; 
    }
    public void displayImage() {
        if(image == null)
              image = new RealImage(filename);
        image.displayImage();
    }
}
 
class ProxyExample {
    public static void main(String[] args) {
        Image image1 = new ProxyImage("HiRes_10MB_Photo1");
        Image image2 = new ProxyImage("HiRes_10MB_Photo2");     
        
        image1.displayImage(); // loading necessary
        image2.displayImage(); // loading necessary
    }
}
```
