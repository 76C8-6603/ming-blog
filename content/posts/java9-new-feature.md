---
    title: "[译]java9新特性：在接口中用pirvate方法让default(java8接口特性)更简练"
    date: 2018-05-09 
    tags: ["java"]
    
---

Java8 带来了许多改变，其中之一就是default修饰的接口方法。

这些方法改变了我们已知的接口，现在我们能够在接口中定义默认实现方法。默认实现方法的不同之处在于，在接口中用default修饰抽象方法后，该方法可以拥有方法体，实现他的方法可以不重写default修饰的方法而且可以直接调用。

 

如果你大量使用default方法在你的应用接口中，你将很快意识到他没有真正精简代码。

因为你不能在接口中提炼default里重复的代码到一个新的普通方法，这与以精简代码为目的的default关键字相冲突。

 

但在java9中这个问题被引入的 private interface methods 解决了。这些新定义的规则可以让你在接口中创建private修饰的方法，这样我们就可以在接口中构造更加简练的代码。

 

利用Java9的 private interface methods 重构 default 方法  
代码实例：

接口--Archive

```java
public interface Archive {

  List<Article> getArticles();

  default List<Article> filterByTitle(String title) {
    return getArticles().stream()
      .filter(article -> article.getTitle().equals(title))
      .collect(Collectors.toList());
  }

  default List<Article> filterByTag(String tag) {
      return getArticles().stream()
        .filter(article -> article.getTags().contains(tag))
        .collect(Collectors.toList());
  }
}
```
正如你所看到的，Archive包含一个抽象方法- getArticles ，和两个default方法- filterByTitle 和 filterByTag 。

 

现在，如果你仔细观察两个default方法，你会发现它们几乎相同。唯一的区别就是在filter方法中使用了不同的谓语而已。

 

这种重复的代码又土又没有必要。理应让default代码更加简练，幸运的是Java9的 private interface method 可以帮上忙。

 

下面是用 private interface methods 重写的Archive：

```java
public interface NewArchive {

  List<Article> getArticles();

  default List<Article> filterByTitle(String title) {
    return filterBy(article -> article.getTitle().equals(title));
  }

  default List<Article> filterByTag(String tag) {
    return filterBy(article -> article.getTags().contains(tag));
  }

  private List<Article> filterBy(Predicate<Article> toFilterBy) {
    return getArticles().stream()
      .filter(toFilterBy)
      .collect(Collectors.toList());
  }
}
```
这就是想要的结果，通过提取除了谓语以外的代码，我们移除了重复的内容，也让代码更具有可读性。

 

*英文链接：[deadCodeRising](http://www.deadcoderising.com/java-9-cleaning-up-your-default-methods-using-private-interface-methods/)

*原创译文