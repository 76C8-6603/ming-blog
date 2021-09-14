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
        return AnnotatedElementUtils.hasMetaAnnotationTypes(methodParameter.getMethod(),ANNOTATION_TYPE);
    }

    /**
     * 包装controller方法的返回结果
     * @param o
     * @param methodParameter
     * @param mediaType
     * @param aClass
     * @param serverHttpRequest
     * @param serverHttpResponse
     * @return
     */
    @Override
    public Object beforeBodyWrite(Object o, MethodParameter methodParameter, MediaType mediaType, Class<? extends HttpMessageConverter<?>> aClass, ServerHttpRequest serverHttpRequest, ServerHttpResponse serverHttpResponse) {
        if (o instanceof ResultEntity) {
            return o;
        }
        return ResultEntity.builder().code(ResponseInfoEnum.SUCCESS.getCode()).msg(ResponseInfoEnum.SUCCESS.getMessage()).data(o).build();
    }

    /**
     * 已知异常处理
     * @param baseException 自定义异常父类
     * @return 异常结果包装
     */
    @ExceptionHandler(value = BaseException.class)
    public ResultEntity baseExceptionHandler(BaseException baseException) {
        log.error(baseException.getMessage(), baseException);
        return baseException.getResultEntity();
    }

    /**
     * 未知异常处理
     * @param e 未知异常
     * @return 异常结果包装
     */
    @ExceptionHandler(value = Exception.class)
    public ResultEntity unknownExceptionHandler(Exception e) {
        log.error(e.getMessage(), e);
        return new BaseException() {
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

public abstract class BaseException extends RuntimeException {

    /**
     * 给前端展示的信息
     */
    private String viewMessage;

    public BaseException(){
        super();
    }

    public BaseException(String message) {
        super(message);
        viewMessage = message;
    }

    public BaseException(String message, Throwable cause) {
        super(message, cause);
        viewMessage = message;
    }

    public BaseException(Throwable cause) {
        super(cause);
    }

    public BaseException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
        viewMessage = message;
    }

    public ResultEntity getResultEntity() {
        ResultEntity resultEntity = new ResultEntity();
        resultEntity.setData(null);
        resultEntity.setCode(getInfoEnum().getCode());
        resultEntity.setMsg(viewMessage == null ? getInfoEnum().getMessage() : viewMessage);
        return resultEntity;
    }

    /**
     * 获取{@link ResponseInfoEnum}
     * @return
     */
    protected abstract ResponseInfoEnum getInfoEnum();

}

```

# 测试异常子类
```java
public class TestException extends BaseException {
    private final ResponseInfoEnum responseInfoEnum = ResponseInfoEnum.TEST_EXCEPTION;

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
    protected ResponseInfoEnum getInfoEnum() {
        return responseInfoEnum;
    }
}
```

# 异常信息枚举
```java
public enum ResponseInfoEnum {
    TEST_EXCEPTION(1001,"测试异常");
    //异常码
    private int code;

    //异常信息
    private String msg;


    ResponseInfoEnum(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
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
    String value() default "未知异常";
    @AliasFor("value")
    String msg() default "未知异常";
    Class<? extends BaseException> defaultException() default UnknownException.class;
}
```

## `@DefaultEx`注解
```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface DefaultEx {
    Class<? extends BaseException> value();
}
```

## 切面代码：
```java
@Aspect
@Component
public class UnknownExceptionAdvice {

    @Pointcut("within(com.test..*)")
    public void withinPackage() {}

    /**
     * 方法被注解{@link UnknownEx}修饰，或者类被{@link DefaultEx}修饰
     * @param joinPoint 切面信息
     * @param ex 方法本来抛出的异常
     */
    @AfterThrowing(pointcut = "(@annotation(com.ds.console.annotation.UnknownEx) || @target(com.ds.console.annotation.DefaultEx))" +
            "&& withinPackage() "
            , throwing = "ex"
            , argNames = "joinPoint, ex"
    )
    public void unknownExceptionHandler(JoinPoint joinPoint, Throwable ex) throws Throwable {
        if (ex instanceof BaseException) {
            throw ex;
        }else{
            BaseException baseException;
            try {
                baseException = buildException(joinPoint, ex);
            } catch (Exception e) {
                throw new BaseException() {
                    @Override
                    protected ErrorCode getInfoEnum() {
                        return ErrorCode.UNEXPECTED_ERROR;
                    }
                };
            }
            throw baseException;
        }
    }

    /**
     * 获取默认异常class，可以从类上的{@link DefaultEx}获取，或者从方法上的{@link UnknownEx#defaultException()}获取
     * @param joinPoint 切面信息
     * @param ex 方法本来抛出的异常
     * @return BaseException的实现类
     */
    private BaseException buildException(JoinPoint joinPoint, Throwable ex) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {
        BaseException exception;
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        UnknownEx unknownEx = signature.getMethod().getAnnotation(UnknownEx.class);
        DefaultEx defaultEx = joinPoint.getTarget().getClass().getAnnotation(DefaultEx.class);

        if (unknownEx != null) {
            //如果方法有UnknownEx注解
            Class<? extends BaseException> baseEx = unknownEx.defaultException();
            if (baseEx == UnknownException.class && defaultEx != null) {
                //如果unknownEx注解的异常类为空，并且类有DefaultEx注解
                baseEx = defaultEx.value();
            }
            String msg = unknownEx.msg();
            if(StringUtils.isNotEmpty(msg)) {
                exception = baseEx.getConstructor(String.class,Throwable.class).newInstance(msg,ex);
            }else{
                exception = baseEx.getConstructor(Throwable.class).newInstance(ex);
            }
        }else {
            //如果方法没有UnknownEx注解，那么类必定有DefaultEx注解
            exception = defaultEx.value().getConstructor(Throwable.class).newInstance(ex);
        }

        return exception;

    }
}

```