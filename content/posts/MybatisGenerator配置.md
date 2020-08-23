---
    title: "Mybatis Generator配置"
    date: 2019-07-15 
    tags: ["mybatis"]
    
---

配置复杂，比较臃肿，推荐使用idea的插件easyCode

pom.xml配置：
```xml
<!-- mybatis自动生成 start -->
<plugin>
    <groupId>org.mybatis.generator</groupId>
    <artifactId>mybatis-generator-maven-plugin</artifactId>
    <version>1.3.2</version>
    <configuration>
        <!--配置文件的位置-->
        <configurationFile>src/main/resources/generatorConfig.xml</configurationFile>
        <verbose>true</verbose>
        <overwrite>true</overwrite>
    </configuration>
    <executions>
        <execution>
            <id>Generate MyBatis Artifacts</id>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>
    <dependencies>
        <dependency>
            <groupId>org.mybatis.generator</groupId>
            <artifactId>mybatis-generator-core</artifactId>
            <version>1.3.2</version>
        </dependency>
    </dependencies>
</plugin>
<!-- mybatis自动生成 end -->
```

配置文件generatorConfig.xml：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE generatorConfiguration
  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">

<generatorConfiguration>
  <classPathEntry location="/Program Files/IBM/SQLLIB/java/db2java.zip" />

  <context id="DB2Tables" targetRuntime="MyBatis3">
　　　　<!--optional,旨在创建class时，对注释进行控制-->        　　　　<commentGenerator>            　　　　　　<property name="suppressDate" value="true" />            　　　　　　<!-- 是否去除自动生成的注释 true：是 ： false:否 -->            　　　　　　<property name="suppressAllComments" value="true" />        　　　　</commentGenerator>
    <jdbcConnection driverClass="COM.ibm.db2.jdbc.app.DB2Driver"
        connectionURL="jdbc:db2:TEST"
        userId="db2admin"
        password="db2admin">
    </jdbcConnection>

    <javaTypeResolver >
      <property name="forceBigDecimals" value="false" />
    </javaTypeResolver>

    <javaModelGenerator targetPackage="test.model" targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
      <property name="trimStrings" value="true" />
    </javaModelGenerator>

    <sqlMapGenerator targetPackage="test.xml"  targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
    </sqlMapGenerator>

    <javaClientGenerator type="XMLMAPPER" targetPackage="test.dao"  targetProject="\MBGTestProject\src">
      <property name="enableSubPackages" value="true" />
    </javaClientGenerator>

    <table schema="DB2ADMIN" tableName="ALLTYPES" domainObjectName="Customer" >
      <property name="useActualColumnNames" value="true"/>
      <generatedKey column="ID" sqlStatement="DB2" identity="true" />
      <columnOverride column="DATE_FIELD" property="startDate" />
      <ignoreColumn column="FRED" />
      <columnOverride column="LONG_VARCHAR_FIELD" jdbcType="VARCHAR" />
    </table>

  </context>
</generatorConfiguration>
```
### 配置文件的注意事项：

这个文件指定得事DB2的驱动，也可以配置其他驱动的路径。
* "Java Type Resolver"的属性force bigDecimal为false - 这意味着整形（Short,Integer,Long,etc.)在可能的情况下将会被替换。这个属性是为了更好地处理数据库的DECIMAL和NUMERIC类型的列。
* "javaModelGenerator"的属性"enableSubPackages"为true。这意味着生成的PO类将会被放到"test.model.db2admin"这个目录下（因为表是在DB2ADMIN这个schema下）。如果"enableSubPackage"属性为false，这个包就会变为"test.model"。同样在"javaModelGenerator"属性下的"trimStrings"意味着在设置po的任何字符串属性时会调用trim方法，这在数据库返回列信息中有空字符串时会有用到。
* "sqlMapGenerator"的属性"enableSubPackages"，跟"javaModelGenerator"的属性"enableSubPackages"原理相同。
* "javaClientGenerator的属性"enableSubPackages"，跟"javaModelGenerator"的属性"enableSubPackages"原理相同。DAO的生成器会生成mapper接口，它为MyBatis引用了一个XML的配置。
* 这个文件只指定了一个表将被内省，但也可以指定多个。关于指定表的注意事项如下：
    + 生成的PO的名称将基于Customer(CustomerKey,Customer,CustoerMapper,etc.)-而不是基于表名。
    + "useActualColumnNames"属性。如果这个属性设为false（或者未被指定），MBG将会取列的驼峰命名。无论何总情况PO的列明都会被<columnOverride>属性覆盖。
    + 列有一个"generatedKey"，它是一个标识列，而且"sqlStatement"是DB2。MBG会在生成<insert>语句时生成一个<selectKey>元素，以便新生成的key能够被返回（使用DB2特定的SQL)。
    + "columnOverrid"属性中的"date_field"将映射到属性"startDate"。这回覆盖默认的"useActualColumnNames"属性所设定的规则。
    + "ignoredColumn"属性中的"FRED"字段将被忽略，没有SQL会列出这个字段，也没有Java属性将被生成。
    + "LONG_VARCHAR_FIELD"将被当作一个"VARCHAR"处理，忽略掉它实际的数据类型。
    
    
### （原文）Important notes about this file follow:

* The file specifies that the legacy DB2 CLI driver will be used to connect to the database, and also specifies where the driver can be found.
* The Java Type Resolver should not force the use of BigDecimal fields - this means that integral types (Short, Integer, Long, etc.) will be substituted if possible. This feature is an attempt to make database DECIMAL and NUMERIC columns easier to deal with.
* The Java model generator should use sub-packages. This means that the generated model objects will be placed in a package called test.model.db2admin in this case (because the table is in the DB2ADMIN schema). If the enableSubPackages attribute was set to false, then the package would be test.model. The Java model generator should also trim strings. This means that the setters for any String properties will call the trim function - this is useful if your database might return blank characters at the end of character columns.
* The SQL Map generator should use sub-packages. This means that the generated XML files will be placed in a package called test.xml.db2admin in this case (because the table is in the DB2ADMIN schema). If the enableSubPackages attribute was set to false, then the package would be test.xml.
* The DAO generator should use sub-packages. This means that the generated DAO classes will be placed in a package called test.dao.db2admin in this case (because the table is in the DB2ADMIN schema). If the enableSubPackages attribute was set to false, then the package would be test.dao. The DAO generator should generate mapper interfaces that reference an XML configuration for MyBatis.
* The file specifies only one table will be introspected, but many more could be specified. Important notes about the specified table include:
* The generated objects will be based on the name Customer (CustomerKey, Customer, CustomerMapper, etc.) - rather than on the table name.
* Actual column names will be used as properties. If this property were set to false (or not specified), then MBG would attempt to camel case the column names. In either case, the name can be overridden by the <columnOverride> element
* The column has a generated key, it is an identity column, and the database type is DB2. This will cause MBG to generate the proper <selectKey> element in the generated <insert> statement so that the newly generated key can be returned (using DB2 specific SQL).
* The column DATE_FIELD will be mapped to a property called startDate. This will override the default property which would be DATE_FIELD in this case, or dateFieldif the useActualColumnNames property was set to false.
* The column FRED will be ignored. No SQL will list the field, and no Java property will be generated.
* The column LONG_VARCHAR_FIELD will be treated as a VARCHAR field, regardless of the actual data type.