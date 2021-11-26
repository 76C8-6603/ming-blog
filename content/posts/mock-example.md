---

    title: "Spring boot mock实例"
    date: 2017-09-20
    tags: ["spring", "test"]

---

```java
@SpringBootTest
class Test{
    @MockBean
    private UserService userService;
    
    @BeforeEach
    void initial(){
        //给定任意参数都返回vip
        BDDMockito.given(
                this.userService.getById(
                        //除了任意参数，还可以：
                        //指定参数 Mockito.eq()
                        //模糊匹配 Mockito.startsWith()
                        //自定义匹配 Mockito.argThat()
                        Mockito.any()
                )).willReturn("vip");
    }

    @Test
    void function1() {
        String userName = userService.getById("123");
        Assert.assertSame(userName, "vip");
    }
}

```