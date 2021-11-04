---

    title: "统一结果处理和业务异常包装"
    date: 2017-08-21
    tags: ["java","spring"]

---
# 完全处理后的controller
```java
@RestController
@DefaultEx(TestException.class)
public class TestController{
    
    @GetMapping
    @UnknownEx("test1 exception")
    public String test(String arg) {
        if(StringUtils.isEmpty(arg)){
            throw new TestException("参数arg不能为空");
        }
        return "test";
    }

    @PostMapping
    @UnknownEx(msg = "test2 exception", baseException = TestException.class)
    public Map<String, String> test2(String arg) {
        //...
        return map;
    }

    /**
     * 因为类注解DefaultEx的存在，这个方法的异常也会被捕获封装
     */
    @GetMapping
    public void test3(String arg) {
        //...    
    }
}
```
统一处理返回结果和业务异常后，不需要在controller写try/catch捕获未知异常，通过`@UnknownExceptionHandler`直接将未知异常包装为包含提示信息的指定业务异常；同时controller的返回值也不需要去手动包装，直接返回即可。  
不管异常还是正常结果，都统一包装为下边的格式：  
```json
{
  "code": 1000,
  "msg": "success",
  "data": {"id": "...","name": "..."...}
}
```

# 统一Exception处理和结果处理

```java
@RestControllerAdvice
@Slf4j
public class CustomResponseBodyAdvice implements ResponseBodyAdvice<Object> {

    private static final Class<? extends Annotation> ANNOTATION_TYPE = RequestMapping.class;

    /**
     * 目标返回值包装方法是元注解中有@RequestMapping的方法
     */
    @Override
    public boolean supports(MethodParameter methodParameter, Class<? extends HttpMessageConverter<?>> aClass) {
        final Method method = methodParameter.getMethod();
        if (method != null) {
            return AnnotatedElementUtils.hasMetaAnnotationTypes(method, ANNOTATION_TYPE);
        }else {
            return false;
        }
    }

    /**
     * 包装controller方法的返回结果
     *
     * @return 重新包装后的controller方法返回
     */
    @Override
    public Object beforeBodyWrite(Object o, MethodParameter methodParameter, MediaType mediaType, Class<? extends HttpMessageConverter<?>> aClass, ServerHttpRequest serverHttpRequest, ServerHttpResponse serverHttpResponse) {
        //目前只对void的controller方法进行结果包装，不影响之前有返回的接口，或者返回文件流的接口。
        if (o == null) {
            return new ResultEntity(
                    BizCodeEnum.SUCCESS.getCode()
                    , BizCodeEnum.SUCCESS.getMessage()
                    ,null
            );
        }else {
            return o;
        }
    }

    /**
     * 已知异常处理
     *
     * @param bizException 自定义异常父类
     * @return 异常结果包装
     */
    @ExceptionHandler(value = BizException.class)
    public ResultEntity baseExceptionHandler(BizException bizException) {
        log.error(bizException.getMessage(), bizException);
        return bizException.getResult();
    }

    /**
     * 未知异常处理
     *
     * @param ex 未知异常
     * @return 异常结果包装
     */
    @ExceptionHandler(value = Exception.class)
    public ResultEntity exception(Exception ex) {
        log.error(ex.getMessage(), ex);
        return new BizException() {
            @Override
            protected ResponseInfoEnum getInfoEnum() {
                return ResponseInfoEnum.UNKNOWN_EXCEPTION;
            }
        }.getResultEntity();
    }

}
```


# 异常父类
```java
public abstract class BizException extends RuntimeException {

    /**
     * 给前端展示的信息
     */
    private String viewMessage;

    protected BizException(){
        super();
    }

    protected BizException(String message) {
        super(message);
        viewMessage = message;
    }

    protected BizException(String message, Throwable cause) {
        super(message, cause);
        viewMessage = message;
    }

    protected BizException(Throwable cause) {
        super(cause);
    }

    protected BizException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
        viewMessage = message;
    }

    public ResultEntity<?> getResult() {
        return new ResultEntity<>(
                getInfoEnum().getCode()
                ,viewMessage == null ? getInfoEnum().getMessage() : viewMessage
                ,null
        );
    }

    public String getViewMessage() {
        return viewMessage;
    }

    /**
     * 获取{@link BizCodeEnum}
     * @return 异常枚举
     */
    protected abstract BizCodeEnum getInfoEnum();

}

```

# 测试异常子类
```java
public class TestException extends BizException {
    private final static BizCodeEnum ERROR = BizCodeEnum.TEST_EXCEPTION;

    public TestException() {
        super();
    }

    public TestException(String message) {
        super(message);
    }

    public TestException(String message, Throwable cause) {
        super(message, cause);
    }

    public TestException(Throwable cause) {
        super(cause);
    }

    public TestException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    @Override
    protected BizCodeEnum getInfoEnum() {
        return ERROR;
    }
}
```

# 未知异常子类
```java
public class UnknownException extends BizException{
    private BizCodeEnum exceptionEnum = BizCodeEnum.UNKNOW_EXCEPTION;

    public UnknownException() {
    }

    public UnknownException(String message) {
        super(message);
    }

    public UnknownException(String message, Throwable cause) {
        super(message, cause);
    }

    public UnknownException(Throwable cause) {
        super(cause);
    }

    public UnknownException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

    @Override
    protected BizCodeEnum getInfoEnum() {
        return exceptionEnum;
    }
}

```

# 异常信息枚举
```java
public enum BizCodeEnum {

    SUCCESS(0, "success")
    ,UNKNOW_EXCEPTION(10000,"系统未知异常")
    ,TEST_EXCEPTION(11000, "测试异常")
    ;

    private Integer code;

    private String message;

    BizCodeEnum(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    public Integer getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
```

# 统一返回对象
```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResultEntity<T> {
    private int code;
    private String msg;
    private T data;
}
```

# 异常处理切面
## `@UnknownEx`注解
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface UnknownEx {
    @AliasFor("msg")
    String value() default "";
    @AliasFor("value")
    String msg() default "";
    Class<? extends BizException> defaultException() default UnknownException.class;
}
```

## `@DefaultEx`注解
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface DefaultEx {
    Class<? extends BizException> value();
}
```

## 切面代码：
```java
@Aspect
@Component
public class UnknownExceptionAdvice {

    @Pointcut("within(com.test..*)")
    public void withinPackage() {
        //pointcut表达式
    }

    /**
     * 方法被注解{@link UnknownEx}修饰，或者类被{@link DefaultEx}修饰
     *
     * @param joinPoint 切面信息
     * @param ex        方法本来抛出的异常
     */
    @AfterThrowing(pointcut = "(@annotation(com.test.exception.annotation.UnknownEx) || @target(com.test.exception.annotation.DefaultEx))" +
            "&& withinPackage() "
            , throwing = "ex"
            , argNames = "joinPoint, ex"
    )
    public void unknownExceptionHandler(JoinPoint joinPoint, Throwable ex) {
        if (ex instanceof BizException) {
            throw (BizException) ex;
        } else {
            try {
                throw buildException(joinPoint, ex);
            } catch (BizException e) {
                throw e;
            } catch (Exception e) {
                throw new UnknownException();
            }
        }
    }

    /**
     * 获取默认异常class，可以从类上的{@link DefaultEx}获取，或者从方法上的{@link UnknownEx#defaultException()}获取
     *
     * @param joinPoint 切面信息
     * @param ex        方法本来抛出的异常
     * @return BizException的实现类
     */
    private BizException buildException(JoinPoint joinPoint, Throwable ex) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
        BizException exception;
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        UnknownEx unknownEx = signature.getMethod().getAnnotation(UnknownEx.class);
        DefaultEx defaultEx = joinPoint.getTarget().getClass().getAnnotation(DefaultEx.class);

        if (unknownEx != null) {
            //如果方法有UnknownEx注解
            Class<? extends BizException> baseEx = unknownEx.defaultException();
            if (baseEx == UnknownException.class && defaultEx != null) {
                //如果unknownEx注解的异常类为空，并且类有DefaultEx注解
                baseEx = defaultEx.value();
            }
            //AliasFor对反射无效，需要手动处理
            String msg = unknownEx.msg();
            String value = unknownEx.value();
            if (StringUtils.isNotEmpty(msg) || StringUtils.isNotEmpty(value)) {
                String bizMsg = msg;
                if (StringUtils.isEmpty(msg)) {
                    bizMsg = value;
                }
                exception = baseEx.getConstructor(String.class, Throwable.class).newInstance(bizMsg, ex);
            } else {
                exception = baseEx.getConstructor(Throwable.class).newInstance(ex);
            }
        } else {
            //如果方法没有UnknownEx注解，那么类必定有DefaultEx注解
            exception = defaultEx.value().getConstructor(Throwable.class).newInstance(ex);
        }

        return exception;

    }
}

```