---
    title: "JOOQ事务处理"
    date: 2019-08-22
    tags: ["jooq","transactional"]
    
---

基于Spring 的`@Transactional`注解，JOOQ可以非常简单的实现事务管理，详细参考[JOOQ-Spring Transactional Management](http://www.jooq.org/doc/3.13/manual/getting-started/tutorials/jooq-with-spring/#N6AB1E)  
这里主要讨论如Spring注解不能介入的情况，或者事务范围小于方法  
```java
create.transaction(configuration -> {
    AuthorRecord author =
    DSL.using(configuration)
       .insertInto(AUTHOR, AUTHOR.FIRST_NAME, AUTHOR.LAST_NAME)
       .values("George", "Orwell")
       .returning()
       .fetchOne();

    DSL.using(configuration)
       .insertInto(BOOK, BOOK.AUTHOR_ID, BOOK.TITLE)
       .values(author.getId(), "1984")
       .values(author.getId(), "Animal Farm")
       .execute();

    // Implicit commit executed here
});
```
注意上面例子中的create虽然就是一个DslContext，但是你不能直接用于实现中，需要获取到他的configuration，重新构造一个  
> 详细参考[Jooq Transactional Management](http://www.jooq.org/doc/3.13/manual/sql-execution/transaction-management/)