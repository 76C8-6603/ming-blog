---

    title: "The alias is already mapped to the value"
    date: 2021-08-27
    tags: ["mybatis"]

---
Mybatis报错
```
The alias is already mapped to the value
```
原因是mybatis扫描的类名有重复的，需要细化扫描路径，或者删除重复类
```yaml
mybatis:
  # 搜索指定包别名
  typeAliasesPackage: com.system,com.api
```
指定路径可以有多个，以逗号分隔即可