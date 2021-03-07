---

    title: "xml序列化和反序列化"
    date: 2018-09-21
    tags: ["java"]

---

# XmlMapper
## 依赖
```xml
<dependency>
    <groupId>com.fasterxml.jackson.dataformat</groupId>
    <artifactId>jackson-dataformat-xml</artifactId>
</dependency>
```

## 基础类

```java
@Data
class SimpleBean {
    private int x = 1;
    private int y = 2;
}
```

## 序列化到xml String
```java
@Test
public void whenJavaSerializedToXmlStr_thenCorrect() throws JsonProcessingException {
    XmlMapper xmlMapper = new XmlMapper();
    String xml = xmlMapper.writeValueAsString(new SimpleBean());
    assertNotNull(xml);
}
```
得到的结果：  
```xml
<SimpleBean>
    <x>1</x>
    <y>2</y>
</SimpleBean>
```

## 序列化到xml File
```java
@Test
public void whenJavaSerializedToXmlFile_thenCorrect() throws IOException {
    XmlMapper xmlMapper = new XmlMapper();
    xmlMapper.writeValue(new File("simple_bean.xml"), new SimpleBean());
    File file = new File("simple_bean.xml");
    assertNotNull(file);
}
```

## 从xml File反序列化
```java
@Test
public void whenJavaGotFromXmlFile_thenCorrect() throws IOException {
    File file = new File("simple_bean.xml");
    XmlMapper xmlMapper = new XmlMapper();

    SimpleBean value = xmlMapper.readValue(file.getInputStream(), SimpleBean.class);
    assertTrue(value.getX() == 1 && value.getY() == 2);
}
```

## 反序列化大写标签
```xml
<SimpleBeanForCapitalizedFields>
    <X>1</X>
    <y>2</y>
</SimpleBeanForCapitalizedFields>
```
需要修改实体类
```java
class SimpleBeanForCapitalizedFields {
    @JacksonXmlProperty("X")
    private int x = 1;
    private int y = 2;

    // standard getters, setters
}
```

## 序列化List到XML
最终想要生成的xml
```xml
<Person>
    <firstName>Rohan</firstName>
    <lastName>Daye</lastName>
    <phoneNumbers>
        <phoneNumbers>9911034731</phoneNumbers>
        <phoneNumbers>9911033478</phoneNumbers>
    </phoneNumbers>
    <address>
        <streetName>Name1</streetName>
        <city>City1</city>
    </address>
    <address>
        <streetName>Name2</streetName>
        <city>City2</city>
    </address>
</Person>
```
注意`<phoneNumbers>`作为列表是经过包装的，而`<address>`也是列表但是没有包装   
像下面这样生成实体类即可
```java
public final class Person {
    private String firstName;
    private String lastName;
    private List<String> phoneNumbers = new ArrayList<>();
    @JacksonXmlElementWrapper(useWrapping = false)
    private List<Address> address = new ArrayList<>();

    //standard setters and getters
}

public class Address {
    String streetName;
    String city;
    //standard setters and getters
}
```

客户端代码
```java
private static final String XML = "<Person>...</Person>";

@Test
public void whenJavaSerializedToXmlFile_thenSuccess() throws IOException {
    XmlMapper xmlMapper = new XmlMapper();
    Person person = testPerson(); // test data
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    xmlMapper.writeValue(byteArrayOutputStream, person); 
    assertEquals(XML, byteArrayOutputStream.toString()); 
}
```

## 反序列化XML到List
实体类像上一个主题中一样配置
```java
@Test
public void whenJavaDeserializedFromXmlFile_thenCorrect() throws IOException {
    XmlMapper xmlMapper = new XmlMapper();
    Person value = xmlMapper.readValue(XML, Person.class);
    assertEquals("City1", value.getAddress().get(0).getCity());
    assertEquals("City2", value.getAddress().get(1).getCity());
}
```