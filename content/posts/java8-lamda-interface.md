---
    title: "[译]Java8的函数式接口"
    date: 2018-08-21
    tags: ["java"]
    
---

Java8引入了 java.util.function 包，他包含了函数式接口，具体的描述在以下api说明文档中：

 

    函数式接口为lambda表达式和方法引用提供目标类型。每个函数式接口有一个单独的抽象方法，被称为函数式接口的函数方法，lambda表达式的参数和返回类型与之匹配或适应。
 

在这篇文章中，将着重介绍function包40个接口中的4个：

 

#### Predicate<T>

    代表有一个参数的断言(boolean值的函数)
Predicate 接口允许我们创建一个基于给定参数并返回一个boolean值的lambda表达式。让我们创建一个Predicate来测试一个Person是否为成年人。

```java
Predicate<Integer> isAnAdult = age -> age >= 18;
```
这里对于stream的filter方法的使用，让Predicate接口作为一个参数。所以我们实际上能够在stream中使用我们的Predicate接口。

```java
Predicate<Person> isAnAdult = person -> person.getAge() >= 18;
List<Person> people = getAllPeople();
Integer numOfAdult = people.stream().filter(isAnAdult).count();
```
 

#### Consumer<T>

    代表一个接受单个参数输入而不返回任何结果的操作。不像大多数其他的函数式接口，Customer预期是通过副作用进行操作。
```java
Consumer<Ticket> ticketPrinter = ticket -> ticket.print();
```
Iterable接口带来的全新forEach方法可以将Consumer作为一个参数，让我们用forEach方法将上面创建的ticketPrinter操作组合在一个Collection上：

```java
Consumer<Ticket> ticketPrinter = ticket -> ticket.print();
Collection<Ticket> tickets = getTicketsToPrint();
tickets.forEach(ticketPrinter);
```
现在，让我们简化一下代码，通过把Consumer直接放进forEach方法中：

```java
Collection<Ticket> tickets = getTicketsToPrint();
tickets.forEach(ticket -> ticket.print());
```
 

#### Supplier<T>

    表示结果供应
这是工厂的一种，他没有参数，只是返回给你一个结果。非常适合返回一个实例。

```java
Supplier<TicketHandler> ticketHandlerCreator = () -> new TicketHandler();
```
另一种方案是使用构造方法引用。

```java
Supplier<TicketHandler> ticketCreator = TicketHandler::new;
```
 

#### Function<T,R>

    表示一个方法接收一个参数然后产出一个结果
让我们直接看一个例子：

```java
Function<String,Predicate<Ticket>> ticketFor = event -> ticket -> event.equals(ticket.getName());
List<Ticket> tickets = getAllTickets();
Integer soldTicketsForCoolEvent = tickets.stream().filter(ticketFor.apply("CoolEvent")).count();
```
我们创建了一个以event字符串作为参数的Function，他会返回一个Predicate。参数会被传给Predicate，并与event字符串作比较。然后我们在stream中使用function去计算ticket name为"CoolEvent"的数量

 

*英文链接：[deadCodeRising](https://www.deadcoderising.com/functional-interfaces-in-java-8/)

*原创译文