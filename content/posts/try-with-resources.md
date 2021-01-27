---

    title: "java7特性try-with-resources"
    date: 2016-08-09
    tags: ["java"]

---
# 概览
try-with-resources表达式可以自动关闭申明在表达式中的资源，但前提是这些资源类要实现`java.lang.AutoCloseable`或者`java.io.Closeable`。  

下面的例子使用`BufferedReader`的实例读取了文件的第一行：  
```java
static String readFirstLineFromFile(String path)throws IOException{
    try(BufferedReader br=
            new BufferedReader(new FileReader(path))){
        return br.readLine();
    }
}
```
因为`BufferedReader`在try-with-resources表达式中，并且他实现了`AutoCloseable`，意味着不管程序运行结果如何，他都会自动关闭。  

但在java7之前，你只有通过finally来完成资源的关闭：  
```java
static String readFirstLineFromFileWithFinallyBlock(String path)
                                                     throws IOException {
    BufferedReader br = new BufferedReader(new FileReader(path));
    try {
        return br.readLine();
    } finally {
        if (br != null) br.close();
    }
}
```
虽然能够达到try-with-resources表达式同样的目的，但是如果try的代码块和finally都同时抛出异常，那么finally的异常就会覆盖掉try的异常。  
但在之前的`readFirstLineFromFile`方法例子中，使用try-with-resources表达式时，如果try-with-resources表达式和try的代码块同时抛出异常，最终抛出的会是try代码块的。  

你有可能同时在try-with-resources表达式中申明多个资源，下面就是一个例子，他解析zip包中的所有文件名，并将他们写入到一个文件中。  
```java
public static void writeToFileZipFileContents(String zipFileName,
                                           String outputFileName)
                                           throws java.io.IOException {

    java.nio.charset.Charset charset =
         java.nio.charset.StandardCharsets.US_ASCII;
    java.nio.file.Path outputFilePath =
         java.nio.file.Paths.get(outputFileName);

    // Open zip file and create output file with 
    // try-with-resources statement

    try (
        java.util.zip.ZipFile zf =
             new java.util.zip.ZipFile(zipFileName);
        java.io.BufferedWriter writer = 
            java.nio.file.Files.newBufferedWriter(outputFilePath, charset)
    ) {
        // Enumerate each entry
        for (java.util.Enumeration entries =
                                zf.entries(); entries.hasMoreElements();) {
            // Get the entry name and write it to the output file
            String newLine = System.getProperty("line.separator");
            String zipEntryName =
                 ((java.util.zip.ZipEntry)entries.nextElement()).getName() +
                 newLine;
            writer.write(zipEntryName, 0, zipEntryName.length());
        }
    }
}
```
在这个例子中，同时申明了两个资源`ZipFile`和`BufferedWriter`，他们通过分号分隔。一旦代码块执行完毕，他们会按照`BufferedWriter`，`ZipFile`的顺序进行关闭。注意，资源创建的顺序和他们被关闭的顺序是相反的。   

下面的例子使用try-with-resources去关闭一个`java.sql.Statement`资源：
```java
public static void viewTable(Connection con) throws SQLException {

    String query = "select COF_NAME, SUP_ID, PRICE, SALES, TOTAL from COFFEES";

    try (Statement stmt = con.createStatement()) {
        ResultSet rs = stmt.executeQuery(query);

        while (rs.next()) {
            String coffeeName = rs.getString("COF_NAME");
            int supplierID = rs.getInt("SUP_ID"); 
            float price = rs.getFloat("PRICE");
            int sales = rs.getInt("SALES");
            int total = rs.getInt("TOTAL");

            System.out.println(coffeeName + ", " + supplierID + ", " + 
                               price + ", " + sales + ", " + total);
        }
    } catch (SQLException e) {
        JDBCTutorialUtilities.printSQLException(e);
    }
}
```
注意： try-with-resources表达式也能像一般try表达式一样申明catch和finally，只不过他们都会在try-with-resources资源关闭之后才会进行

# 被压制的异常
在方法`writeToFileZipFileContents`中，try-with-resources表达式申明了两个资源，在尝试关闭这两个资源的时候可能会抛出两个异常。但如果try的代码块本身也有异常抛出，那么try-with-resources表达式产生的异常就会被压制，想查看这些被压制的异常，可以通过代码块异常的`throwable.getSuppressed`方法来获取。  

# 实现`Closeable`和`AutoCloseable`的类
参考[AutoCloseable](https://docs.oracle.com/javase/8/docs/api/java/lang/AutoCloseable.html) 和[Closeable](https://docs.oracle.com/javase/8/docs/api/java/io/Closeable.html)  分别查看他们的实现类。`Closeable`继承了`AutoCloseable`。当`Closeable`中的`close`方法出错时抛出的是`IOException`，但是`AutoCloseable`的`close`方法抛出的却是`Exception`。因此`AutoCloseable`的实现可以根据具体情况调整抛出的异常。
