---

    title: "no available service 'null' found, please make sure registry config correct"
    date: 2021-09-26
    tags: ["seata"]

---

确保项目中`application.yml`中的`spring.cloud.alibaba.seata.tx-service-group`属性要和`file.conf`文件的`vgroupMapping`属性的后缀相同。  
举个例子：  

```yaml
# application.yml
spring:
  cloud:
    alibaba:
      seata:
        tx-service-group: test-fescar-service-group
```

```conf
# file.conf
service {
    vgroupMapping.test-fescar-service-group = "default"
}
```

> 参考[seata issues](https://github.com/seata/seata/issues/2406)
