---
    title: "[译]Java8：循环与函数式编程"
    date: 2018-08-23
    tags: ["java"]
    
---

Java8函数式编程的加入彻底改变了游戏规则。对Java开发者来说这是一个全新的世界，我们也需要做出相应的改变。

在这篇文章中我们将找寻传统循环代码的可替代方案。Java8的函数式编程特性改变了编程思路，从 “我们怎样去做” 变成了 “我们想做什么” 。  
这也是传统循环的缺点。当然传统循环更加的灵活，但其灵活性并不能掩盖他的问题。  
return、break、continue能直接改变循环的执行流程，强迫我们不仅要理解业务逻辑，同时也要了解循环是怎样工作的。

Java8通过引入stream指令，我们可以在集合上使用强大的函数式操作。现在我们来看看怎样将传统循环转变为更简洁，更具有可读性的代码。

这里将会创建一个Article类，他有三个成员变量：title、author、tags：

```java
private class Article {

    private final String title;
    private final String author;
    private final List<String> tags;

    private Article(String title, String author, List<String> tags) {
        this.title = title;
        this.author = author;
        this.tags = tags;
    }

    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }

    public List<String> getTags() {
        return tags;
    }
}
```

每个例子都会包括一个传统循环的解决方案，和Java8函数式编程的解决方案。

在第一个例子里面，将会在Article集合中寻找tag包含"Java"的第一个对象：

 

传统循环的解决方案：

```java
public Article getFirstJavaArticle(){
    for(Article article : articles){
        if(article.getTags().contains("Java")){
            return article;
        }
    }
    return null;
}
```
Java8的解决方案：

```java
public Optional<String> getFirstJavaArticle(){
  return articles.stream().filter(article -> article.getTags.contains("Java")).findFirst();  
}
```
 

首先我们使用filter操作找到所有符合条件的Article，然后调用findFirst()方法得到第一个。  
因为stream是惰性的而且filter返回了一个stream，因此方法只有在找到第一个匹配时才会去处理这个元素。

现在让我们尝试获取所有匹配的元素。

 

传统循环解决方案：

```java
public List<Article> getAllJavaArticles() {

    List<Article> result = new ArrayList<>();

    for (Article article : articles) {
        if (article.getTags().contains("Java")) {
            result.add(article);
        }
    }

    return result;
}
```
 

Java8解决方案：

```java
public List<Article> getAllJavaArticles() {
    return articles.stream().filter(article -> article.getTags.contains("Java")).collect(Collectors.toList());
}
```
在这个例子中我们使用了 collect 方法去筛选stream，而不是自己声明一个集合，并将匹配的参数追加到集合中。

到目前为止都不错，现在是时候来展现 stream api真正的魅力了！

让我们基于author将articles进行分组。

 

传统循环解决方案：

```java
public Map<String,List<Article>> groupByAuthor(){
    Map<String,List<Article>>  result = new HashMap<>();
    for(Article article : articles){
        if(result.containsKey(article.getAuthor)){
            result.get(article.getAuthor).add(article);
        }else{
            ArrayList<Article> articles = new ArrayList<>();
            articles.add(article);
            result.put(article.getAuthor(), articles);
        }
    }        
}
```
 

Java8解决方案：

```java
public Map<String, List<Article>> groupByAuthor() {
    return articles.stream().collect(Collectors.groupingBy(Article::getAuthor));
}
```
通过使用groupingBy操作和getAuthor的方法引用，我们得到了整洁并且可读性高的代码。

现在，让我们在集合中找到Article所有的不重复的tags。

 

首先时传统循环方案：

```java
public Set<String> getDistinctTags(){
    Set<String> result = new HashSet<>();
    for(Article article : articles){
        result.addAll(article.getTags());
    }
    return result;  
}
```
 

Java8解决方案：

```java
public Set<String> getDistinctTags(){
    return articles.stream().flatMap(article -> article.getTags().stream()).collect(Collectors.toSet());
}
```
flatMap帮助我们获取结果流中的tag集合，然后用collect方法创建一个Set并返回结果。

 

函数式编程拥有无限的可能，这四个例子的目的是怎样将循环替换成更可读的代码。你应该仔细查看stream API，因为相比api这文章仅仅只是皮毛而已。

 

*英文链接：[deadCodeRising](http://www.deadcoderising.com/java-8-no-more-loops/)

*原创译文