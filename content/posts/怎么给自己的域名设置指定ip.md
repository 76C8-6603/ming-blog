---
    title: "怎么给自己的域名指定IP"
    date: 2020-02-20
    tags: ["website build"]
    
---

一般来讲直接指定A record就行，这里以NameCheap为例：

```
//@ - used to point a root domain (yourdomain.tld) to the IP address:
//在浏览器输入yourdomain.tld想跳转到的ip

A Record | @ |  11.22.33.44

//www - is selected when it is needed to point www.yourdomain.tld to the IP address:
//在浏览器输入www.yourdomain.tld想跳转到的ip

A Record | www |  11.22.33.44
```

[NameCheap的详细说明](https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain)