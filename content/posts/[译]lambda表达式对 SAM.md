---
    title: "[译]lambda表达式对 SAM （单个抽象方法类）type的处理方式"
    date: 2018-06-26 
    tags: ["java"]
    
---

在阅读Venkat Subramaniam的著作《Functional Programming in Java》 之后，方法模式和lambda完美结合让我印象深刻。

这种模式经常用作数据源处理，但也适用于类似的情况。这种模式可以让你集中注意力在核心功能点上，而不用担心类里面有过多重复的代码。

这里创建了一个事务处理作为事例。

接口 Transaction，他有一个执行方法。

```java
import java.sql.Connection;
import java.sql.SQLException;

public interface Transaction{
  public void execute(Connection connection) throws SQLException;
}
```
这个接口代表我们想在事务中执行什么操作。这是一个 SAM(Single Abstract Method) 类型，意味着我们能够使用lambda表达式去实现他。

然后我们轮到我们的主角登场，TransactionHandler。

```java
import java.sql.Connection;  
import java.sql.DriverManager;

public class TransactionHandler {

    public static void runInTransaction(Transaction transaction) throws Exception {

        Connection dbConnection = createDatabaseConnection();
        dbConnection.setAutoCommit(false);

        try {

            System.out.println("Starting transaction");
            transaction.execute(dbConnection);


            System.out.println("Committing transaction");
            dbConnection.commit();

        } catch (Exception e) {

            System.out.println(e.getMessage());
            System.out.println("Rolling back...");
            dbConnection.rollback();
        } finally {
            dbConnection.close();
        }
    }

    private static Connection createDatabaseConnection() throws Exception {

        Class.forName("com.mysql.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/ticket_system", "user", "password");
    }
}
```
 他包含了一个静态方法,他的职责是运行我们的事务和在异常情况下回滚.

 我创建了一个简单的票务系统去展示TransactionHandler是怎么样和lambda一起工作的.

首先是一个成功的事务:

```java
@Test
public void testSuccessfulPurchase() throws Exception {

    TransactionHandler.runInTransaction(connection -> {

        int ticketId = findAvailableTicket(connection);

        reserveTicket(ticketId, connection);
        markAsBought(ticketId, connection);
    });

    assertEquals(getNrOfTicketsIn(TicketState.AVAILABLE), 9);
    assertEquals(getNrOfTicketsIn(TicketState.RESERVED), 0);
    assertEquals(getNrOfTicketsIn(TicketState.BOUGHT), 1);
}
```
控制台输出:

    Starting transaction  
    Reserving ticket with id 1  
    Marking ticket with id 1 as bought  
    Committing transaction  
    
然后是失败的事务:

```java
@Test
public void testFailedPurchase() throws Exception {

    TransactionHandler.runInTransaction(connection -> {

        int ticketId = findAvailableTicket(connection);

        reserveTicket(ticketId, connection);
        throw new IllegalStateException("Not approved credit card");
    });

    assertEquals(getNrOfTicketsIn(TicketState.AVAILABLE), 10);
    assertEquals(getNrOfTicketsIn(TicketState.RESERVED), 0);
    assertEquals(getNrOfTicketsIn(TicketState.BOUGHT), 0);
}
```
这个测试预定了一张票,然后抛出异常,触发回滚取消预约;

控制台输出:

    Starting transaction  
    Reserving ticket with id 1  
    Not approved credit card  
    Rolling back...  
    
lambda表达式的处理方式是简洁优雅的，而匿名内部类需要创建类并实例化他，你不觉得他有些太罗嗦了吗?

留意我们是如何使用lambda表达式作为一个工具去测试TransactionHandler的每个方面

你能在这里找到完整的例子 [GitHub](https://github.com/mariushe/exercise/tree/master/transactions)

*英文链接：[deadCodeRising](http://www.deadcoderising.com/transactions-using-execute-around-method-in-java-8/)

*原创译文

