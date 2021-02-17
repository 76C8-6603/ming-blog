---
    title: "Request的Body只能读取一次解决方法"
    date: 2018-03-06 
    tags: ["java"]
    
---

 #### 一、需要一个类继承HttpServletRequestWrapper，该类继承了ServletRequestWrapper并实现了HttpServletRequest，

 因此它可作为request在FilterChain中传递。

 该类需要重写getReader和getInputStream两个方法，并在返回时将读出的body数据重新写入。

 #### 二、需要一个Filter筛选目标urlPattern，调用第一个类的同时，将第一个类写入FilterChain中代替原本的Request
 
 
 ```java
package com.bonc.util;

import javax.servlet.ReadListener;
import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import java.io.*;

public class BodyReaderRequestWrapper extends HttpServletRequestWrapper {
    private final String body;

    /**
     *
     * @param request
     */
    public BodyReaderRequestWrapper(HttpServletRequest request) throws IOException{
        super(request);
        StringBuilder sb = new StringBuilder();
        InputStream ins = request.getInputStream();
        BufferedReader isr = null;
        try{
            if(ins != null){
                isr = new BufferedReader(new InputStreamReader(ins));
                char[] charBuffer = new char[128];
                int readCount = 0;
                while((readCount = isr.read(charBuffer)) != -1){
                    sb.append(charBuffer,0,readCount);
                }
            }else{
                sb.append("");
            }
        }catch (IOException e){
            throw e;
        }finally {
            if(isr != null) {
                isr.close();
            }
        }

        sb.toString();
        body = sb.toString();
    }

    @Override
    public BufferedReader getReader() throws IOException {
        return new BufferedReader(new InputStreamReader(this.getInputStream()));
    }

    @Override
    public ServletInputStream getInputStream() throws IOException {
        final ByteArrayInputStream byteArrayIns = new ByteArrayInputStream(body.getBytes());
        ServletInputStream servletIns = new ServletInputStream() {
            @Override
            public boolean isFinished() {
                return false;
            }

            @Override
            public boolean isReady() {
                return false;
            }

            @Override
            public void setReadListener(ReadListener readListener) {

            }

            @Override
            public int read() throws IOException {
                return byteArrayIns.read();
            }
        };
        return  servletIns;
    }
}
```

```java
package com.bonc.bitwd.filter;

import com.bonc.util.BodyReaderRequestWrapper;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class BodyReaderRequestFilter implements Filter{
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest)req;
        HttpServletResponse response = (HttpServletResponse)res;
        BodyReaderRequestWrapper requestWrapper  = new BodyReaderRequestWrapper(request);
        if(requestWrapper == null){
            filterChain.doFilter(request,response);
        }else {
            filterChain.doFilter(requestWrapper,response);
        }
    }

    @Override
    public void destroy() {

    }
}
```