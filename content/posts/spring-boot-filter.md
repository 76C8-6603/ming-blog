---

    title: "Spring boot filter"
    date: 2018-01-16
    tags: ["spring"]

---

# 全局filter

```java

@Component
@Order(1)
public class FirstFilter extends Filter {
    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        ...
        chain.doFilter(request, response);
    }
}
```
全局过滤直接实现Filter即可，如需设定顺序，使用`@Order`注解  

# URL Pattern Filter
过滤指定的URL，需要通过注册Bean的形式：  
```java
@Configuration
public class FilterBeanConfiguration{
    @Bean
    public FilterRegistrationBean<SecondFilter> secondFilter(){
        FilterRegistrationBean<SecondFilter> registrationBean
                = new FilterRegistrationBean<>();

        registrationBean.setFilter(new SecondFilter());
        registrationBean.addUrlPatterns("/users/*");

        return registrationBean;
    }
}
```

```java
@Order(2)
public class SecondFilter extends Filter {
    @Override
    public void doFilter(
            ServletRequest request,
            ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        ...
        chain.doFilter(request, response);
    }
}
```
注意通过`FilterRegistrationBean`注册的filter，不能被`@Component`修饰