---

    title: "easyapi插件个性化配置"
    date: 2021-11-11
    tags: ["yapi","idea"]

---
easyapi个性化配置[easyapi-config-rule](https://easyyapi.com/setting/config-rule.html)  
实例：需要统一屏蔽从token获取的用户id（requestAttribute），可以添加如下配置：  

```
param.ignore=userId
```
需要保证参数名为userId，例：
```java
@GetMapping
public ResultEntity test(@RequestAttribute Long userId){}
```