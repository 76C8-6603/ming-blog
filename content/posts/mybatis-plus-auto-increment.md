---

    title: "Mybatis-plus 非自增id插入报错的问题"
    date: 2019-12-04
    tags: ["mybatis"]

---

在id上加注解`@TableId(type = IdType.INPUT)`，代表非自增id，需要手动指定
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User extends Model<AccountTransaction> {

    /**
     * id
     */
    @TableId(type = IdType.INPUT)
    private Long id;

    /**
     * 名称
     */
    private Long name;

}
```