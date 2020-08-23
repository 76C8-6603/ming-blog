---
    title: "FastJson解析结果部分属性为null的问题"
    date: 2019-07-02 
    tags: ["java"]
    
---

在协作开发时，从接口获取到的json实体部分为空，但是在调试时发现原对象没有任何问题，但是经过解析成为json后，部分属性变为：

"$ref":"$.*******“

改变解析方式为Gson问题解决，经查是fastjson在解析json时，会将json中相同的内容改为引用导致

这么做的原因是防止实体类中有自引用，解析的时候出现死循环，从而导致栈内存溢出

可以通过设置取消fastjson的引用，但是可能出现内存溢出风险，需要自行评估

```java
JSONArray.toJSONString(jsonArray, SerializerFeature.DisableCircularReferenceDetect);
JSONObject.parse(JSONArray.toJSONString(jsonArray, SerializerFeature.DisableCircularReferenceDetect));
```