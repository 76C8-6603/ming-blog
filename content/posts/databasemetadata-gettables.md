---

    title: "DatabaseMeta getTables 为空"
    date: 2021-06-24
    tags: ["java"]

---
`java.sql.DatabaseMetaData`类提供对数据库元数据进行查找的一系列方法，包括获取表名`getTables`，获取schema`getSchemas`，获取列名`getColumns`等等  
这里展示目标实例获取数据库的所有表：  
```java
List<String> tableNames = new ArrayList<>();
Connection conn = fetchConnection(sourceDb);
ResultSet rs = conn.getMetaData().getTables(conn.getCatalog(), null, null, new String[]{"TABLE"});
while (rs.next()) {
    tableNames.add(rs.getString(3));
}
```
注意`getTables`方法的四个参数，分别是：
1. catalog
2. schema patterns
3. tableName patterns   表名过滤
4. types  表类型过滤，可能的值有："TABLE", "VIEW", "SYSTEM TABLE", "GLOBAL TEMPORARY", "LOCAL TEMPORARY", "ALIAS", "SYNONYM".

四个参数都是对最终展示table的筛选，他们都可以为null，为null就代表没有对应筛选条件  

这里需要注意的是，每个数据库都根据自身的情况去实现了`getTables`方法，前面两个参数根据数据库的实现可能有不同的含义或者范围。  
在不确定的情况下，可以直接从Connection中获取:
```java
getTables(conn.getCatalog(), conn.getSchema(), null, new String[]{"TABLE"});
```