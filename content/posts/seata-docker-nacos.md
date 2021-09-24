---

    title: "seata-docker-nacos"
    date: 2021-09-24
    tags: ["seata"]

---
### 背景
通过docker拉取的官方镜像，没有指定版本。但是在配置nacos的时候，出现无法注册的情况。官方文档和网上的文章大部分都围绕`file.conf`和`registry.conf`两个文件进行配置，但是实践过程中，没有在`/seata-server/resources/`目录下发现这两个文件，并且手动新增后也没有任何效果。

根据[官方镜像仓库](https://hub.docker.com/r/seataio/seata-server/tags?page=1&ordering=last_updated) 确定拉下来的是1.5的版本，但是官网和大部分文章都是基于1.4.2或以前的版本进行的配置，实测在1.5上完全不能生效。

### 解决方案
* 手动指定版本到1.4.2然后根据`file.conf`和`registry.conf`两个文件进行配置（网上文章很多，这里不做赘述）
* 1.5版本需要修改`/seata-server/resources/`目录下的`application.yml`文件(下面主要针对这种情况进行阐述)

1.5版本`/seata-server/resources/`目录下是没有`file.conf`和`registry.conf`两个文件的，所有的配置需要在`application.yml`中配置，并且也提供了事例文件`application-example.yml`


