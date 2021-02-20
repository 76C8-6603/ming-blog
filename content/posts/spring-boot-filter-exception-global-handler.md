---

    title: "Springboot filter异常全局处理"
    date: 2019-01-08
    tags: ["spring"]

---

# 背景
controller的全局异常处理可以通过`@RestControllerAdvice` `@ExceptionHandler`来处理。但是如果filter中出了异常，controller的全局异常是无法捕获的。  

# 解决方案
找到filter chain中执行的第一个filter，在他的`chain.doFilter()`方法上加try-catch进行filter全局异常处理。这个filter就是`OncePerRequestFilter`。  
但这只在没有指定filter顺序的时候生效，如果你给任何Filter手动指定了顺序（比如通过`Order(1)`），那么`OncePerRequestFilter`就无法保证第一个执行。  

```java
public class ExceptionHandlerFilter extends OncePerRequestFilter {

    private final ObjectMapper objectMapper;

    public ExceptionHandlerFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    protected void doFilterInternal(@NotNull HttpServletRequest httpServletRequest, @NotNull HttpServletResponse httpServletResponse, FilterChain filterChain) throws ServletException, IOException {
        try {
            filterChain.doFilter(httpServletRequest, httpServletResponse);
        } catch (BaseException e) {
            writeException(e, httpServletResponse, objectMapper.writeValueAsString(e.getResultEntity()));
        } catch (Exception e) {
            writeException(e, httpServletResponse, objectMapper.writeValueAsString(ResponseInfoEnum.UNKNOWN_EXCEPTION.buildResultEntity()));
        }
    }

    private void writeException(Exception e, HttpServletResponse httpServletResponse, String writeValueAsString) throws IOException {
        log.error(e.getMessage(), e);
        httpServletResponse.setStatus(HttpStatus.HTTP_OK);
        httpServletResponse.setContentType(ContentType.JSON.toString());
        httpServletResponse.setCharacterEncoding("utf-8");
        httpServletResponse.getWriter().append(writeValueAsString);
    }
}
```
注意`BaseException`是业务异常的顶级父类，因此在自定义的filter中，可以抛出业务异常，向调用方展示业务异常信息。  
另外未发现的异常也会被捕获，作为UNKNOWN_EXCEPTION抛出。  

如果有其他Filter手动指定了顺序，那么上面的方法就不起作用了。这时需要通过`@Order(Ordered.HIGHEST_PRECEDENCE)`修饰（推荐此方法），`OncePerRequestFilter`不再是必要条件：  
```java
@Order(Ordered.HIGHEST_PRECEDENCE)
@Slf4j
@Component
public class ExceptionHandlerFilter implements Filter {

    private final ObjectMapper objectMapper;

    public ExceptionHandlerFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletResponse httpServletResponse = (HttpServletResponse) response;
        try {
            chain.doFilter(request, response);
        } catch (BaseException e) {
            writeException(e,httpServletResponse,objectMapper.writeValueAsString(e.getResultEntity()));
        } catch (Exception e) {
            writeException(e,httpServletResponse,objectMapper.writeValueAsString(ResponseInfoEnum.UNKNOWN_EXCEPTION.buildResultEntity()));
        }
    }
    

    private void writeException(Exception e, HttpServletResponse httpServletResponse, String writeValueAsString) throws IOException {
        log.error(e.getMessage(), e);
        httpServletResponse.setStatus(HttpStatus.HTTP_OK);
        httpServletResponse.setContentType(ContentType.JSON.toString());
        httpServletResponse.setCharacterEncoding("utf-8");
        httpServletResponse.getWriter().append(writeValueAsString);
    }

    
}
```