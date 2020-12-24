---

    title: "java8 lambda reduce&collect"
    date: 2017-09-25
    tags: ["java"]

---
# Reduction
首先看一个例子：  
```java
double average = roster
    .stream()
    .filter(p -> p.getGender() == Person.Sex.MALE)
    .mapToInt(Person::getAge)
    .average()
    .getAsDouble();
```
像上面的例子一样，JDK还包含很多其他的终端操作（比如说average,sum,min,max,和count），他们合并了stream中的内容并返回单一的结果。这些操作被统一称为`Reduction operations`。JDK同样包含可以返回集合而不是一个值的reduction操作.大多数reduction操作针对的都是特定情况，比如找平均值或者按照目录分组等。但是，JDK同样也提供了通用的reduction操作，他们是`reduce`和`collect`。  

# Stream.reduce
下面的例子目的是求名册中男性成员的年龄总和  
首先使用Stream.sum的方式
```java
Integer totalAge = roster
    .stream()
    .mapToInt(Person::getAge)
    .sum();
```
下面用Stream.reduce计算同样的结果
```java
Integer totalAgeReduce = roster
    .stream()
    .map(Person::getAge)
    .reduce(
            0,
        (a,b) -> a + b);
        )
```
这个reduce操作有两个参数：  
* `identity`：它既是reduction计算的初始值也是在流没有任何元素的时候的默认值。这个例子中`identity`的值是0，也就是求和的初始化值是0，并且如果roster流中没有任何元素，最后返回的结果也是0。  
* `accumulator`：这个`accumulator`方法有两个参数：一个是reduction的部分结果（在这个例子里面，就是到目前为止所有年龄的和），另外一个是流的下一个元素（在这个例子中就是下一个年龄数）。它返回了一个新的部分结果。在这个例子中，`accumulator`方法是一个将两个`Integer`相加并返回`Integer`相加结果的lambda表达式：  
  (a,b) -> a + b  
  
这个`reduce`操作始终返回一个新的值。但是，这个`accumulator`方法在每次处理流中的一个元素后，也返回一个新的值。假定你想处理的stream更复杂，比如内部都是集合。这样可能对性能造成影响。比如你的reduce操作是合并集合，那么每次你的`accumulator`方法在处理一个元素时，都会创建一个新的集合去执行合并操作，这样毫无效率可言。在这种情况下，更适合使用`Stream.collect`方法。
  
# Stream.collect
不像`reduce`方法每次处理元素都会创建一个新的值，`collect`方法是修改或者改变一个已经存在的值。  

思考一下你要怎样求出stream中元素的平均值。你需要的是元素总数和元素的总和。但是，像`reduce`方法和所有其他的reduction方法一样，`collect`方法也只能返回一个值。你可以创建一个新的数据类型包含追踪总数和总和的成员变量，就像下面的类`Averager`：

```java
import java.util.function.IntConsumer;

class Averager implements IntConsumer {
  private int total = 0;
  private int count = 0;

  public double average() {
    return count > 0 ? (double) total / count : 0;
  }


  @Override
  public void accept(int value) {
    total += value;
    count++;
  }

  public void combine(Averager that) {
    total += that.total;
    count += that.count;
  }
}
```

下面的例子使用`Averager`类和`collect`方法去获取所有男性的平均年龄：  
```java
Averager averager = roster.stream()
    .filter(p -> p.getGender() == Person.Sex.MALE)
    .map(Person::getAge)
    .collect(Averager::new, Averager::accept, Averager::combine);
double averageNum = averager.average();
```
这个例子中的collect有三个参数：  
* `supplier`：它是一个工厂方法，构建一个新的实例。`supplier`为collect操作提供一个实例作为结果容器。在这个例子中，就是`Averager`类的实例。  
* `accumulator`：它将一个stream的成员合并到结果容器中。在这个例子中，它通过每次给count+1和给total加上当前流中的年龄数值来`修改`Averager`结果容器。  
* `combiner`：它代表了你要如何合并两个结果容器。在这个例子中，就是合并两个结果容器中的count和total。  

注意事项：  
* `supplier`是一个lambda表达式（或者一个方法引用），而不是像`reduce`操作中的identity元素。  
* `accumulator`和`combiner`方法都不返回值。  
* 可以在并发流上使用`collect`操作，详情参考[Parallelism](https://docs.oracle.com/javase/tutorial/collections/streams/parallelism.html) 。如果你在并发流上运行collect方法，那么每当`combiner`方法创建一个新的对象，就像上面例子的`Averager`对象，JDK就会创建一个新的线程。因此，你不需要担心同步的问题。  

虽然JDK已经提供了`average`操作计算流元素的平均值，但是如果你需要计算多个结果值的时候，可以通过`collect`和一个自定义类来获得。  

`collect`操作完美适配集合。下面的例子展示了如何通过collect获取男性成员的所有名称集合：  
```java
List<String> names = roster.stream()
      .filter(p -> p.getGender() == Person.Sex.MALE)
    .map(p -> p.getName())
    .collect(Collectors.toList());
```
上面的`collect`方法只有一个`Collector`参数。这个`Collector`方法内部其实就是封装了之前三个参数的collect方法。  

`Collectors`除了toList还封装了很多常用的reduction操作，比如累加元素到集合中和根据各种条件汇总元素。这些reduction操作返回`Collector`类的实例，所以你可以将他们作为`collect`操作的参数。  

上面例子中的`Collectors.toList`操作是将流中所有的元素添加到一个新的`List`中。像大多数`Collectors`中的操作一样，`toList`返回的是一个`Collector`的实例，而不是一个集合。  

下面的例子是根据`roster`的性别分组：  
```java
Map<Person.Sex, List<Person>> byGender =
    roster
        .stream()
        .collect(
            Collectors.groupingBy(Person::getGender));
```
`groupingBy`操作，根据参数中的lambda表达式分类，并将它作为结果Map的Key值。像这个例子中，Key值就是`Person.Sex.Male`和`Person.Sex.Female`。  

下面的例子检索流元素的所有名称，并根据性别分类： 
```java
Map<Person.Sex, List<String>> namesByGender =
    roster
        .stream()
        .collect(
            Collectors.groupingBy(
                Person::getGender,                      
                Collectors.mapping(
                    Person::getName,
                    Collectors.toList())));
```
这个groupingBy操作有两个参数，一个分类方法和一个`Collector`实例。这个`Collector`参数叫做`downstream collector`。这个collector会在Java运行时应用到另外一个collector的结果上。因此这个`groupingBy`操作让你可以应用一个`collect`方法到由`groupingBy`操作创建的`List`值上。在这个例子中，应用了`mapping` collector，它将`Person::getName`方法应用到stream的每个元素上。隐私，结果会得到一个由成员名称组成的流。一个管道流包含一个或者多个`downstream collectors`，向上面例子这样，被叫做`multilevel reduction`。  

下面的例子检索每个性别的年龄总和：  
```java
Map<Person.Sex, Integer> totalAgeByGender =
        roster
        .stream()
        .collect(
          Collectors.groupingBy(
            Person::getGender,
            Collectors.reducing(
              0,
              Person::getAge,
              Integer::sum)));
```
这个`reducing`操作有三个参数：  
* `identity`：就像`Stream.reduce`操作中声明的一样，可以作为初始化值，或者流为空时的默认值。  
* `mapper`：`reducing`操作会将这个mapper应用到每个stream元素。在这个例子中，mapper就是为了检索所有的成员的年龄。  
* `operation`：这个操作方法是用来reduce由mapper处理的值的。在这个例子中，就是Integer的加法操作。  

下面的例子检索每个性别的平均年龄：  
```java
Map<Person.Sex, Double> averageAgeByGender = roster
    .stream()
    .collect(
        Collectors.groupingBy(
            Person::getGender,                      
            Collectors.averagingInt(Person::getAge)));
```