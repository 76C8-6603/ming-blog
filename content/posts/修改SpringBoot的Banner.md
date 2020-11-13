---
    title: "修改SpringBoot日志打印时候的标志"
    date: 2017-04-15
    tags: ["spring"]
    
---

#### 1.新建banner.txt在resources目录下
```text
     _/_/_/  _/    _/  _/_/_/  _/      _/    _/_/    
  _/        _/    _/    _/    _/_/    _/  _/    _/   
 _/        _/_/_/_/    _/    _/  _/  _/  _/_/_/_/    
_/        _/    _/    _/    _/    _/_/  _/    _/     
 _/_/_/  _/    _/  _/_/_/  _/      _/  _/    _/      
                                                     
```
[文本图形生成器](http://www.network-science.de/ascii/)
#### 2.开关控制
```java
@SpringBootApplication
public class Application {
	public static void main(String[] args) {
		SpringApplication springApplication = new SpringApplication(Application.class);
        //控制banner是否展示
		springApplication.setBannerMode(Banner.Mode.OFF);
		springApplication.run(args);
	}

}
```