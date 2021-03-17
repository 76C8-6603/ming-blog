---

    title: "Spring Cloud eurake"
    date: 2020-12-27
    tags: ["spring cloud","eureka"]
---

从Spring Cloud 2020.0.0版本开始，Spring Cloud删除了大量的Netflix组件。因为Netflix官方声明，不再为这些组件添加新属性，只做必要的bug维护。  
Eureka是Spring Cloud唯一保留的Netflix组件。作为服务发现组件，除了Eureka，还有Alibaba Nacos，Consul，ZooKeeper，和Kubernetes。  

# Eureka
`Eureka`是netflix开源的服务发现组件，它解决的是CAP中的AP问题。  
`Eureka`分为服务端和客户端：  
* 服务端负责注册管理服务  
* 客户端分两类
    * 服务提供者
    * 服务消费者
## Server
要配置一个 Eureka 只需要三步：  
1. 引入Maven依赖
2. 在Spring Boot入口类上加上注释`@EnableEurekaServer`
3. 配置properties/yml属性

### Maven
```xml
<properties>
        <spring-cloud.version>2020.0.1</spring-cloud.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
    </dependencies>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```
### 入口类
```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }

}
```

### yml
```yaml
eureka:
  client:
    serviceUrl:
      defaultZone: http://peer1:8080/eureka/,http://peer2:8081/eureka/,http://peer3:8082/eureka/

---
server:
  port: 8080

spring:
  application:
    name: Eureka-Server
  profiles: peer1

eureka:
  instance:
    hostname: peer1

---
server:
  port: 8081

spring:
  application:
    name: Eureka-Server
  profiles: peer2

eureka:
  instance:
    hostname: peer2

---
server:
  port: 8082

spring:
  application:
    name: Eureka-Server
  profiles: peer3

eureka:
  instance:
    hostname: peer3
```

## Provider Client
跟服务配置一样，也需要对Maven，入口类，和配置进行修改
### Maven
```xml
  <properties>
    <spring-cloud.version>2020.0.1</spring-cloud.version>
</properties>
<dependencies>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
</dependencies>
<dependencyManagement>
<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-dependencies</artifactId>
        <version>${spring-cloud.version}</version>
        <type>pom</type>
        <scope>import</scope>
    </dependency>
</dependencies>
</dependencyManagement>
```

### 入口类
```java
@SpringBootApplication
@EnableDiscoveryClient
public class EurakeClientProviderApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurakeClientProviderApplication.class, args);
    }

}
```
### yml
```yaml
server:
  port: 8083

spring:
  application:
    name: Server-Provider

eureka:
  client:
    serviceUrl:
      defaultZone: http://peer1:8080/eureka/,http://peer2:8081/eureka/,http://peer3:8082/eureka/

```

## Consumer Client
跟服务配置一样，也需要对Maven，入口类，和配置进行修改。  
除了这三个地方，还需要spring cloud集成的负载均衡机制来调用服务提供者。

### Maven
```xml
  <properties>
        <spring-cloud.version>2020.0.1</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-loadbalancer</artifactId>
        </dependency>

    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

### 入口类
```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
@EnableDiscoveryClient
public class EurakeClientConsumerApplication {

    @Bean
    @LoadBalanced
    RestTemplate restTemplate() {
        return new RestTemplate();
    }

    public static void main(String[] args) {
        SpringApplication.run(EurakeClientConsumerApplication.class, args);
    }

}
```

### yml
```yaml
server:
  port: 9000

spring:
  application:
    name: Server-Consumer

eureka:
  client:
    serviceUrl:
      defaultZone: http://peer1:8080/eureka/,http://peer2:8081/eureka/,http://peer3:8082/eureka/
```

### code
访问方式不是直接指向服务ip和端口，而是用`Eureka`的注册应用名代替
```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class TestController {
    @Autowired
    private RestTemplate restTemplate;
    

    @GetMapping("/info")
    public String getInfo() {
        return this.restTemplate.getForEntity("http://Server-Provider/info", String.class).getBody();
    }
    @GetMapping("/hello")
    public String hello() {
        return this.restTemplate.getForEntity("http://Server-Provider/hello", String.class).getBody();
    }
}
```