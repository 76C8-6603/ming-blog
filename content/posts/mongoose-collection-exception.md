---

    title: "Mongoose Cannot read property collection of undefined"
    date: 2021-05-24
    tags: ["mongodb","js"]

---
# 异常位置
```js
mongoose.connection.db.collection('user')
```
# 异常信息
```
Error: Cannot read property 'collection' of undefined
```

# 结局方案
因为mongoose版本原因（具体版本待确定），新版本调用方式改变。如下面的代码，删掉`db`：
```js
mongoose.connection.collection('user')
```
> 参考[mongoose issues](https://github.com/Automattic/mongoose/issues/6631)