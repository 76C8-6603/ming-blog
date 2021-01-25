---

    title: "业务异常Exception包装"
    date: 2017-08-21
    tags: ["java"]

---
# 包装工后的Exception
```java
public class TestController{
    public ResultEntity test(String arg) {
        if(StringUtils.isEmpty(arg)){
            throw new TestException("参数arg不能为空");
        }
    }   
}
```
# 统一Exception处理

```java
@Slf4j
@RestControllerAdvice
public class CustomExceptionHandler {
    @ExceptionHandler(value = BaseException.class)
    public ResultEntity baseExceptionHandler(BaseException baseException) {
        log.error(baseException.getMessage(),baseException)
        return baseException.getResultEntity();
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
     * 获取{@link ExceptionInfoEnum}
     * @return
     */
    protected abstract ExceptionInfoEnum getInfoEnum();

}

```

# 测试异常子类
```java
public class TestException  extends BaseException {
    /**
     * 每个子异常绑定一个异常枚举，包含默认异常展示信息
     */
    private static final ExceptionInfoEnum TEST_EXCEPTION = ExceptionInfoEnum.TEST_EXCEPTION;
    public TestException(String message) {
        super(message);
    }

    public TestException() {
        super();
    }

    public TestException(String message, Throwable cause) {
        super(message, cause);
    }

    public TestException(Throwable cause) {
        super(cause);
    }

    @Override
    protected ExceptionInfoEnum getInfoEnum() {
        return TEST_EXCEPTION;
    }
}
```

# 异常信息枚举
```java
public enum ExceptionInfoEnum {
    TEST_EXCEPTION(1001,"测试异常");
    //异常码
    private int code;

    //异常信息
    private String msg;


    ExceptionInfoEnum(int code, String msg) {
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
public class ResultEntity{
    private int code;
    private String msg;
    private Object data;
}
```