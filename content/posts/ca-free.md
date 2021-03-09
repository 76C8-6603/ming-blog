---

    title: "免费CA机构"
    date: 2017-05-13
    tags: ["website build"]

---

CA机构颁发HTTPS所需要的TLS证书，一般在域名服务商处就可以购买。也有免费的CA提供商`Let's Encrypt`  
> 详情参考[Let's Encrypt](https://letsencrypt.org/getting-started/)  

### 通过certbot和nginx生成ssl证书
```shell
sudo apt install python-certbot-nginx
sudo certbot --nginx
sudo systemctl restart nginx
```

### 定时任务更新证书
```shell
sudo crontab -e
```
在文件中添加下面的表达式，开头就是cron
```
0 9 * * * certbot renew --post-hook "systemctl reload nginx"
```

### 启用HTTPS/2
编辑对应的域名配置文件
```shell
sudo vi /etc/nginx/sites-available/example.com
```
检查以下配置
```
listen 443 ssl; # managed by Certbot
```
改为：
```
listen 443 ssl http2; # managed by Certbot
```

### 启用客户端的缓存
编辑对应的域名配置文件
```shell
sudo vi /etc/nginx/sites-available/example.com
```
添加如下配置：
```
server{
    # ...
    # Stuff
    # ...

    # Media
    location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|mp4|ogg|ogv|webm|htc)$ {
        expires 30d;
    }

    # CSS and Js
    location ~* \.(css|js)$ {
        expires 7d;
    }
```
