---

    title: "装饰模式"
    date: 2017-01-07
    tags: ["design pattern"]

---
# 简介
> 动态地给一个对象添加一些额外的职责，就增加功能来说，装饰模式比生成子类更加灵活。  

装饰模式常用在为主类添加一些特有的功能的时候。装饰模式可以在不修改主类的情况下对主类进行扩展，并且每个扩展功能也互相独立，不需要知道整个流程。    

装饰模式和建造者模式不同，它是对一个不稳定的组成结构进行封装，代表着结构中的顺序，成员的必要性都不一定，但是建造者模式一般是一个相对稳定的结构。  

# 类图
![Decorator_UML_class_diagram.svg.png](Decorator_UML_class_diagram.svg.png)

# 代码
Component类
```java
// The Window interface class
public interface Window {
	public void draw(); // Draws the Window
	public String getDescription(); // Returns a description of the Window
}


// implementation of a simple Window without any scrollbars
public class SimpleWindow implements Window {
	public void draw() {
		// Draw window
	}

	public String getDescription() {
		return "simple window";
	}
}

```

装饰者及其实现类
```java
// abstract decorator class - note that it implements Window
public abstract class WindowDecorator implements Window {
    protected Window decoratedWindow; // the Window being decorated

    public WindowDecorator (Window decoratedWindow) {
        this.decoratedWindow = decoratedWindow;
    }
    
    @Override
    public void draw() {
        decoratedWindow.draw();
    }

    @Override
    public String getDescription() {
        return decoratedWindow.getDescription();
    }
}


// The first concrete decorator which adds vertical scrollbar functionality
public class VerticalScrollBar extends WindowDecorator {
	public VerticalScrollBar(Window windowToBeDecorated) {
		super(windowToBeDecorated);
	}

	@Override
	public void draw() {
		super.draw();
		drawVerticalScrollBar();
	}

	private void drawVerticalScrollBar() {
		// Draw the vertical scrollbar
	}

	@Override
	public String getDescription() {
		return super.getDescription() + ", including vertical scrollbars";
	}
}


// The second concrete decorator which adds horizontal scrollbar functionality
public class HorizontalScrollBar extends WindowDecorator1 {
	public HorizontalScrollBar (Window windowToBeDecorated) {
		super(windowToBeDecorated);
	}

	@Override
	public void draw() {
		super.draw();
		drawHorizontalScrollBar();
	}

	private void drawHorizontalScrollBar() {
		// Draw the horizontal scrollbar
	}

	@Override
	public String getDescription() {
		return super.getDescription() + ", including horizontal scrollbars";
	}
}
```

测试代码
```java
public class Main {
	// for print descriptions of the window subclasses
	static void printInfo(Window w) {
		System.out.println("description:"+w.getDescription());
	}
	public static void main(String[] args) {
		// original SimpleWindow
		SimpleWindow sw = new SimpleWindow();
		printInfo(sw);
		// HorizontalScrollBar  mixed Window
		HorizontalScrollBar hbw = new HorizontalScrollBar(sw);
		printInfo(hbw);
		// VerticalScrollBar mixed Window
		VerticalScrollBar vbw = new VerticalScrollBar(hbw);
		printInfo(vbw);
	}
}
```