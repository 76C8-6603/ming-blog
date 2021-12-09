---

    title: "rabbitmq延迟队列"
    date: 2021-06-20
    tags: ["mq"]

---

> [x-delay官方文档](https://github.com/rabbitmq/rabbitmq-delayed-message-exchange)  
> rabbitmq自身无法实现延迟队列，需要借助插件，插件安装参考[rabbitmq延迟插件安装](https://blog.tianshiming.com/2021/05/rabbitmq-delay-plugin/)  

以下实例是基于SpringBoot AMQP为基础
### Configuration

````java

@Configuration
public class MyRabbitMQConfig {

    /**
     * 延迟单位：一天标准时间
     */
    public static final Long DELAY_ONE_DAY = 1000 * 60 * 60 * 24L;

    /**
     * 延迟队列
     */
    public static final String QUEUE_NAME = "queue.xdelay.create";


    /**
     * delay exchange
     */
    public static final String EXCHANGE_XDELAY = "exchange.xdelay";

    /**
     * 延时路由键，绑定 {@link #QUEUE_NAME} 到 {@link #EXCHANGE_XDELAY}
     */
    public static final String DELAY_ROUTINGKEY = "routingkey.xdelay";

    @Bean
    public Queue delayQueue() {
        return new Queue(QUEUE_NAME);
    }

    @Bean
    public CustomExchange delayExchange() {
        Map<String, Object> args = new HashMap<String, Object>();
        args.put("x-delayed-type", "direct");
        return new CustomExchange(EXCHANGE_XDELAY, "x-delayed-message", true, false, args);
    }

    @Bean
    public Binding delayBinding() {
        return BindingBuilder.bind(delayQueue()).to(delayExchange()).with(DELAY_ROUTINGKEY).noargs();
    }

}

````

### 发布

```java

@Service
public class DelayService {
    @Autowired
    private RabbitTemplate rabbitTemplate;

    /**
     * 延迟两天
     */
    public void delay(User user) {
        final long delayTime = MyRabbitMQConfig.DELAY_ONE_DAY * 2;
        rabbitTemplate.convertAndSend(MyRabbitMQConfig.EXCHANGE_XDELAY, routingKey, user, message -> {
            message.getMessageProperties().setHeader(MessageProperties.X_DELAY, delayTime);
            return message;
        });
    }
}
```

```java
public class User implements Serializable {
    ...
}
```


### 消费
正常监听队列即可
```java
@Slf4j
@RabbitListener(queues = MyRabbitMQConfig.QUEUE_NAME)
@Service
public class DelayListener {

	@Autowired
	private UserService userService;


	@RabbitHandler
	public void listener(User user, Channel channel, Message message) throws IOException {
		try {
			//最终执行延迟任务
            userService.delayTask(user);

			channel.basicAck(message.getMessageProperties().getDeliveryTag(), false);
		} catch (Exception e) {
			if (Boolean.TRUE.equals(message.getMessageProperties().getRedelivered())) {
				log.info("消息已重复处理失败,拒绝再次接收...");
				channel.basicReject(message.getMessageProperties().getDeliveryTag(), false);
			} else {
				log.error("消息异常原因:{}", e.getMessage(), e);
				log.info("消息即将再次返回队列处理...");
				channel.basicNack(message.getMessageProperties().getDeliveryTag(), false, true);
			}
		}
	}

}
```
