---

    title: "Bucket4j 实例"
    date: 2019-04-11
    tags: ["website build"]

---
# 简介
Bucket4j 是一个基于令牌桶算法的限流工具  
> 官网[git hub](https://github.com/vladimir-bukhtoyarov/bucket4j/tree/4.0)

# 实例
下面实例的场景是，限制被第三方调用的频率，每个app在一个秒钟之内只能有10次请求，但是允许暂时的过载，瞬时最大的访问量是50。
```java
import io.github.bucket4j.Bucket4j;

public class ThrottlingFilter implements javax.servlet.Filter {

    private Bucket createNewBucket() {
         long overdraft = 50; 
         Refill refill = Refill.greedy(10, Duration.ofSeconds(1));
         Bandwidth limit = Bandwidth.classic(overdraft, refill);
         return Bucket4j.builder().addLimit(limit).build();
    }
    
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) servletRequest;
        HttpSession session = httpRequest.getSession(true);

        String appKey = SecurityUtils.getThirdPartyAppKey();
        Bucket bucket = (Bucket) session.getAttribute("throttler-" + appKey);
        if (bucket == null) {
            bucket = createNewBucket();
            session.setAttribute("throttler-" + appKey, bucket);
        }

        // tryConsume returns false immediately if no tokens available with the bucket
        HttpServletResponse httpResponse = (HttpServletResponse) servletResponse;
        ConsumptionProbe probe = bucket.tryConsumeAndReturnRemaining(1);
        if (probe.isConsumed()) {
            // the limit is not exceeded
            httpResponse.setHeader("X-Rate-Limit-Remaining", "" + probe.getRemainingTokens());
            filterChain.doFilter(servletRequest, servletResponse);
        } else {
            // limit is exceeded
            HttpServletResponse httpResponse = (HttpServletResponse) servletResponse;
            httpResponse.setStatus(429);
            httpResponse.setHeader("X-Rate-Limit-Retry-After-Seconds", "" + TimeUnit.NANOSECONDS.toSeconds(probe.getNanosToWaitForRefill()));
            httpResponse.setContentType("text/plain");
            httpResponse.getWriter().append("Too many requests");
        }
    }

}
```

> 更多实例参考[Bucket4j examples](https://github.com/vladimir-bukhtoyarov/bucket4j/blob/4.0/doc-pages/basic-usage.md#basic-usage-examples)