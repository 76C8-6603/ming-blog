---
    title: "Jackson使用解析"
    date: 2017-04-26
    tags: ["jackson","spring"]
    
---

## Jackson简介
Spring在`@RequestBody`和`@ResponseBody`中对对象的反序列化和序列化，都是借助Jackson来实现的，如果想改变Spring序列化或者反序列化的规则，可以通过调整Spring内部`ObjectMapper`bean的属性来实现：
```java
@Configuration
public class JacksonConfig{
    @Bean
    public ObjectMapper getObjectMapper(){
        ObjectMapper objectMapper = new ObjectMapper();
        //该例子将实体类的Date类型跟指定格式的日期字符串对应
        objectMapper.setDateFormat(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"));
        return objectMapper; 
    }
}
```  

Jackson `ObjectMapper`的一般使用
```java
public void test(){
    User user = new User();
    ...
    ObjectMapper mapper = new ObjectMapper();
    //序列化
    String json = mapper.writeValueAsString(user);
    //解析Json为树形结构
    JsonNode node = mapper.readTree(json);
    String name = node.get("name").toText();
    //解析Json为指定类的对象
    User user1 = mapper.readValue(json,User.class);
}
```
更多使用情景可以参考[Jackson-docs](https://github.com/FasterXML/jackson-docs)
## Jackson的扩展注解
### `@JsonProperty`
作用在类的属性上，为其添加一个别名，会影响序列化的属性名称
```java
public class User implements Serializable{
    @JsonProperty("sName")
    private String name;
}
```
```json
{"sName":"赵四"}
```
### `@JsonIgnore`
作用在类的属性上，序列化时忽略某个属性
```java
public class User implements Serializable{
    @JsonIgnore
    private String name; 
}
```
### `@JsonIgnoreProperties`
作用在类上，批量忽略类属性
```java
@JsonIgnoreProperties({"age","sex"})
public class User
```
注意，如果属性有别名，那么就写别名，比如要忽略之前的属性`name`，因为他有别名，所以应该在`@JsonIgnoreProperteis`中填写他的别名`sName`

### `@JsonFormat`
作用在属性上，格式化属性  
一般用来格式化日期
```java
public class User implements Serializable{
    @JsonFormat(pattern="yyyy-MM-dd HH:mm:ss")
    private Date date;
}
```

### `@JsonNaming`
作用在类或者属性上，改变序列化属性的命名规则
```java
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class User implements Serializable{
    private String userName;
}
```
上面的`SnakeCaseStrategy`规则，会将属性userName转为Json属性`user-name`

### `@JsonSerialize`
作用在类上，代表指定自己的序列化规则类
```java
@JsonSerialize(UserSerializer.class)
public class User implements Serializable{}
```
下面要实现自定义序列化规则，需要继承抽象类`JsonSerializer`
```java
public class UserSerializer extends JsonSerializer<User>{
    @Override
    public void serialize(User user, JsonGenerator generator, SerializerProvider provider)
            throws IOException, JsonProcessingException {
        generator.writeStartObject();
        generator.writeStringField("public-info", user.getPublicInfo());
        generator.writeEndObject();
    }
}
```

### `@JsonDeserialize`
作用在类上，代表指定自己的反序列化规则类
```java
@JsonDeserialize(UserDeserializer.class)
public class User implements Serializable{}
```
下面要实现自定义反序列化规则，需要继承抽象类`JsonDeserializer`
```java
pbulic class UserDeserializer extends JsonDeserializer<User>{
    @Override
    public User deserialize(JsonParser parser, DeserializationContext context)
            throws IOException, JsonProcessingException {
        JsonNode node = parser.getCodec().readTree(parser);
        String publicInfo = node.get("public-info").asText();
        User user = new User();
        user.setPublicInfo(publicInfo);
        return user;
    }
}
```

### `@JsonView`
作用在类的属性上和返回`User`的方法上，比如返回该对象的controller方法，`@JsonView`可以让两个方法虽然返回的同一个实例，但是展示的字段却不相同
```java
public class User implements Serializable{
    @JsonView(AllField.class)
    private String id;
    @JsonView(JustName.class)
    private String name;
    @JsonView(AllField.class)
    private String sex;
    
    public interface JustName{}
    public interface AllField extends JustName{}

}
```
用不同接口代表不同的view，使用继承的方式，可以避免一些重复的声明  
下面是调用方法的申明：
```java
@GetMapping("get/name")
@ResponseBody
@JsonView(User.JustName.class)
public User getUserName(){}

@GetMapping("get/all")
@ResponseBody
@JsonView(User.AllField.class)
public User getAllUserField(){}
```
假设上面两个方法的方法体完全相同，因为JsonView的原因，第一个方法只会返回`{"name":"赵四"}`，而第二个方法则会返回四哥的所有信息  

> 更多jackson注解参考[jackson annotation](https://github.com/FasterXML/jackson-docs/wiki/JacksonAnnotations)

## Jackson泛型
```java
String json = "[{\"name\":\"赵四\"}]"
List<User> users = objectMapper.readValue(json,List.class);
User user = users.get(0);
```
上面的代码会在第三行的时候抛出异常：linkedHashMap cannot cast to User  
因为objectMapper反序列化的时候并没有提供List的泛型，jackson内部并不知道list子元素是什么类型，所以默认转为了LinkedHashMap  
jackson提供了泛型处理：  
```java
JavaType type = TypeFactory.defaultInstance.constructParametricType(List.class, User.class);
List<User> list = mapper.readValue(json, type);
```

除了上面的方式，还可以通过`TypeReference`类来处理，下面是一个将POJO转为Map的例子：  
```java
ObjectMapper mapper = new ObjectMapper();

// Convert POJO to Map
Map<String, Object> map = 
    mapper.convertValue(foo, new TypeReference<Map<String, Object>>() {});

// Convert Map to POJO
Foo anotherFoo = mapper.convertValue(map, Foo.class);
```




