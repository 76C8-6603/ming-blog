---
    title: "怎么给自己的域名指定IP"
    date: 2020-02-20
    tags: ["architecture"]
    
---
### 这里主要参照NameCheap，其他域名服务商大同小异
**host:**  
`@`代表在浏览器输入yourdomain.tld想跳转到的地址  
`www`代表在浏览器输入www.yourdomain.tld想跳转到的地址
### 跳转到指定IP  

|type|host|target|
|---|---|---|
|A Record | @ |  11.22.33.44|
|A Record | www |  11.22.33.44|

### 跳转到指定域名

|type|host|target|
|---|---|---|
|CNAME Record|@|[name].github.io
|CNAME Record|www|[name].github.io


[NameCheap的详细说明](https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain)