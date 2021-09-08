---

    title: "获取用户ip失败，获取到的是容器ip"
    date: 2021-09-07
    tags: ["nginx", "java"]

---
### 背景
获取用户ip失败，代码参考[java-获取用户ip](https://blog.tianshiming.com/2017/08/request-get-client-id/)  
最终获取到的是容器ip

### 原因
经确认获取到的容器ip是前端容器的ip。前端容器中包含nginx环境，并对请求进行了统一转发  
下面是nginx的配置文件
```lombok.config
server {
    location ^~/product/ {                                                                                                                                                                          
        proxy_pass   https://1.1.1.1:8080/;                                                                                                                                                                                                                                                                                                      
    }
}
```

### 解决方案
添加代理header配置，让后端能够获取到真实ip：
```lombok.config
server {
    location ^~/product/ {
  
        proxy_set_header Host $http_host;                                                                                                                                                            
        proxy_set_header X-Real-IP $remote_addr;                                                                                                                                                     
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;                                                                                                                                 
        proxy_set_header X-Forwarded-Proto $scheme;  
                                                                                                                                                                                   
        proxy_pass   https://1.1.1.1:8080/;                                                                                                                                                                                                                                                                                                      
    }
}
```

修改完nginx配置文件需要执行命令，才能立即生效：  
```shell
nginx -s reload
```