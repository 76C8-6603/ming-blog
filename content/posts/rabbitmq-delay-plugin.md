---

    title: "rabbitmq延迟队列插件安装"
    date: 2021-05-18
    tags: ["mq"]

---

## 延迟队列下载地址
[x-delay release](https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases)

## 安装方式
```shell
# 将下载插件传到rabbitmq容器中
docker cp rabbitmq_delayed_message_exchange-3.9.0.ez rabbit:/plugins/

# 进入rabbitmq容器
docker exec -it rabbitmq /bin/bash  

# 执行命令安装插件
rabbitmq-plugins enable rabbitmq_delayed_message_exchange

```