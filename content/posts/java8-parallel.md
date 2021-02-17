---

    title: "Java8 lamda表达式中的parallel"
    date: 2017-09-27
    tags: ["java"]

---
# 概览
Java8为集合流处理提供了并发支持。并且就算集合不是线程安全的，你也可以在不修改集合的状态下，对集合进行并发汇总操作。但是这里面仍有一些限制和需要注意的情况，同时你也需要根据数据的实际情况来决定是否需要并发处理。  

# 并发申明
你可以通过并行或者串行的方式执行流。默认情况下所有的流都是串行的，如果需要并行，可以通过`Collection.parallelStream`或者调用某个operation的`BaseStream.parallel`。  
```java
double average = roster
    .parallelStream()
    .filter(p -> p.getGender() == Person.Sex.MALE)
    .mapToInt(Person::getAge)
    .average()
    .getAsDouble()
```
上面的例子是并发求取所有男性成员的平均年龄。  

# 并发Reduction
默认串行reduction操作：
```java
Map<Person.Sex, List<Person>> byGender =
    roster
        .stream()
        .collect(
            Collectors.groupingBy(Person::getGender));
```
上面的例子将所有成员按性别分组  

下面是并行reduction：  
```java
ConcurrentMap<Person.Sex, List<Person>> byGender =
    roster
        .parallelStream()
        .collect(
            Collectors.groupingByConcurrent(Person::getGender));
```

可以看到不光是`parallelStream`的区别，还有`groupingByConcurrent`。要确定collect操作是否是并发，要满足以下三个条件：  
* `parallelStream`。
* collect操作的参数，必须包含特征：[Collector.Characteristics.CONCURRENT](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collector.Characteristics.html#CONCURRENT) 。通过调用[Collector.characteristics](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collector.Characteristics.html) 来决定一个collector的特征属性。  
* 要么stream是无序的，要么collector有[Collector.Characteristics.UNORDERED](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collector.Characteristics.html#UNORDERED) 特性。通过调用[BaseStream.unordered](https://docs.oracle.com/javase/8/docs/api/java/util/stream/BaseStream.html#unordered--) 来确保Stream是无序的。  

注意：上面用了ConcurrentMap和groupingByConcurrent，都是因为性能的原因。因为他们能更好的适配parallelStream带来更高的性能。  

# 排序
流处理元素的顺序取决于它是并行还是串行的，并且还有中间操作的影响。默认情况下串行的流是按照集合顺序执行的，并行的情况顺序无法保证，但是在迭代时你可以使用`forEachOrdered`来代替`forEach`强制并行流按照顺序遍历，但是这会损耗性能，跟并行的初衷相违。  
```java
Integer[] intArray = {1, 2, 3, 4, 5, 6, 7, 8 };
List<Integer> listOfIntegers =
    new ArrayList<>(Arrays.asList(intArray));

System.out.println("listOfIntegers:");
listOfIntegers
    .stream()
    .forEach(e -> System.out.print(e + " "));
System.out.println("");

System.out.println("listOfIntegers sorted in reverse order:");
Comparator<Integer> normal = Integer::compare;
Comparator<Integer> reversed = normal.reversed(); 
Collections.sort(listOfIntegers, reversed);  
listOfIntegers
    .stream()
    .forEach(e -> System.out.print(e + " "));
System.out.println("");
     
System.out.println("Parallel stream");
listOfIntegers
    .parallelStream()
    .forEach(e -> System.out.print(e + " "));
System.out.println("");
    
System.out.println("Another parallel stream:");
listOfIntegers
    .parallelStream()
    .forEach(e -> System.out.print(e + " "));
System.out.println("");
     
System.out.println("With forEachOrdered:");
listOfIntegers
    .parallelStream()
    .forEachOrdered(e -> System.out.print(e + " "));
System.out.println("");
```
print:
```java
listOfIntegers:
1 2 3 4 5 6 7 8
listOfIntegers sorted in reverse order:
8 7 6 5 4 3 2 1
Parallel stream:
3 4 1 6 2 5 7 8
Another parallel stream:
6 3 1 5 7 8 4 2
With forEachOrdered:
8 7 6 5 4 3 2 1
```

# 副作用
流的`collect`操作对并发情况有良好的的支持，但是像`forEach`和`peek`这种操作，不适用于并发流，他们可能被并发的在多个线程处理多次，并且他们的结果无法估计，还会产生副作用。除了两个遍历操作，像System.out这种返回void的调用，在lambda表达式中除了带来副作用没有任何意义。还要注意像`filter`和`map`操作的lambda表达式参数，需要确保他们不会产生任何副作用。  

# 惰性
流的中间操作都不是立即执行的，他们再被申明过后，都会等待最后一个终端操作（比如之前的forEach和collect）的出现，才开始被调用。因为这个特性，在申明流的中间操作时，需要特别注意不要有干扰和状态化的lambda表达式出现。  

# 错误的干扰
下面的例子是一个错误的干扰性的中间操作申明：  
```java
try {
    List<String> listOfStrings =
        new ArrayList<>(Arrays.asList("one", "two"));
         
    // This will fail as the peek operation will attempt to add the
    // string "three" to the source after the terminal operation has
    // commenced. 
             
    String concatenatedString = listOfStrings
        .stream()
        
        // Don't do this! Interference occurs here.
        .peek(s -> listOfStrings.add("three"))
        
        .reduce((a, b) -> a + " " + b)
        .get();
                 
    System.out.println("Concatenated string: " + concatenatedString);
         
} catch (Exception e) {
    System.out.println("Exception caught: " + e.toString());
}
```
上面的例子在peek操作中给集合源添加了一个元素。按照之前的惰性说明，流操作的执行的开始是在终端操作出现之后。当流开始处理，这时候peek操作修改源数据，就会抛出`ConcurrentModificationException`。

# 不该出现的状态化lambda表达式
```java
List<Integer> serialStorage = new ArrayList<>();
     
System.out.println("Serial stream:");
listOfIntegers
    .stream()
    
    // Don't do this! It uses a stateful lambda expression.
    .map(e -> { serialStorage.add(e); return e; })
    
    .forEachOrdered(e -> System.out.print(e + " "));
System.out.println("");
     
serialStorage
    .stream()
    .forEachOrdered(e -> System.out.print(e + " "));
System.out.println("");

System.out.println("Parallel stream:");
List<Integer> parallelStorage = Collections.synchronizedList(
    new ArrayList<>());
listOfIntegers
    .parallelStream()
    
    // Don't do this! It uses a stateful lambda expression.
    .map(e -> { parallelStorage.add(e); return e; })
    
    .forEachOrdered(e -> System.out.print(e + " "));
System.out.println("");
     
parallelStorage
    .stream()
    .forEachOrdered(e -> System.out.print(e + " "));
System.out.println("");
```
` e -> { parallelStorage.add(e); return e; }`在这里是一个状态化的lambda表达式，在parallel的情况下他的执行结果可能是难以预料的：
```java
Serial stream:
8 7 6 5 4 3 2 1
8 7 6 5 4 3 2 1
Parallel stream:
8 7 6 5 4 3 2 1
1 3 6 2 4 5 8 7
```

注意，这里使用了`Collections.synchronizedList`来包装并发的List，如果没有这个逻辑，直接申明一个ArrayList来接收并发流生成的list，那么可能会产生多个线程同时修改一个对象的情况，结果可能像这样：  
```java
Parallel stream:
8 7 6 5 4 3 2 1
null 3 5 4 7 8 1 2
```