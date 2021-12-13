---

    title: "java.time"
    date: 2020-05-17
    tags: ["java"]

---
传统的`Date`、`Calendar`、`SimpleDateFormat`等日期操作类，没有明确的时区观念，要进行时区设置，比较麻烦。在跟database交互时也有不少坑（例如[Mybatis日期注入时区问题](https://blog.tianshiming.com/2019/01/mybatis-date-param-timezone/) ）  
同时传统日期操作类在进行日期修改和转换时也比较麻烦，一个简单的日期计算和格式化，动则十几行代码  

从java8开始，`java.time`包被引入，目的是代替传统的日期操作，新的日期操作类分为以下几种：  
* 实时，不指定时区（Instant）
* 实时，指定时区（OffsetDateTime,ZonedDateTime）
* 静态，不带时区（LocalDateTime,LocalDate,LocalTime,OffsetTime）  

> 以上的实时代表时间是真实存在时间线上的某个时间点，不指定时区就是默认的UTC(Instant)，可以借此获取时间戳等信息（相当于Date）。指定时区需要在申明时间的时候手动指定，或者获取系统默认的时区（默认时区指定方法，Spring boot可以通过启动类指定`TimeZone.setDefault(TimeZone.getTimeZone(ZoneId.of("Asia/Shanghai")));`）  

> 静态没有时区属性，不指代任何时间线上的时间点。在跨时区使用时，或是特指某个时间点时有用。比如`2077-01-01 00:00:00`，指2077年的新年，他可以运用在每个时区，但是因为时区不同具体的实现肯定不同。  

以下是具体使用实例
```java
public class TimeTest {


    /**
     * 获取当前时区的时间点，并且格式化为'yyyy-MM-dd HH:mm:ss'
     */
    @Test
    void test1() {
        TimeZone.setDefault(TimeZone.getTimeZone(ZoneId.of("Asia/Shanghai")));
        final ZonedDateTime now = ZonedDateTime.now();
        final String format = now.format(DateTimeFormatter.ofLocalizedDateTime(FormatStyle.MEDIUM));
        System.out.println(format);
    }

    /**
     * 将Instant转为ZonedDateTime，并且自定义日期格式化
     */
    @Test
    void test2() {
        final Instant instant = Instant.now();
        final ZonedDateTime zonedDateTime = instant.atZone(ZoneId.of("Asia/Shanghai"));
        final String format = zonedDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HHmmss"));
        System.out.println(format);
    }

    /**
     * 获取当前日期的时间戳
     */
    @Test
    void test3() {
        final Instant now = Instant.now();
        final long l = now.toEpochMilli();
        System.out.println(l);
    }

    /**
     * 获取当前日期，并把日期初始化为当月1号，最后获取七天前的静态日期
     */
    @Test
     void test5() {
        final LocalDate localDate = ZonedDateTime.now().withDayOfMonth(1).minusDays(7).toLocalDate();
        System.out.println(localDate);
    }
    
}
```

> 以上的时区用的是'Asia/Shanghai'，更多时区可以参考[wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)  

> 本文参考[https://stackoverflow.com/questions/32437550/whats-the-difference-between-instant-and-localdatetime/32443004#32443004](https://stackoverflow.com/questions/32437550/whats-the-difference-between-instant-and-localdatetime/32443004#32443004)  

> 上文中提及`ZonedDateTime`和`Instant`不能直接通过jdbc传递，但经过项目实验，直接传递这两个实体可以完全替代`Date`，没有发现任何问题（Spring boot项目，Mybatis-plus版本3.4.2，Mysql驱动版本8.0.23）
