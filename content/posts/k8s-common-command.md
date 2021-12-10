---

    title: "k8s常用命令"
    date: 2019-10-11
    tags: ["k8s"]

---

```shell
# 获得K8S集群下的所有命名空间
kubectl get ns

# 获得某个命名空间下的所有的pod信息
kubectl get pod -n <name-space>	

# 获得某个命名空间下的所有的服务信息,可以查看服务的ip/port等信息
kubectl get svc -n <name-space>	

# 一般在pod部署失败的情况查看一下,pod相关的信息
kubectl describe pods <pod-name> -n <name-space>	

# 进入pod内部,查看pod的内部信息
kubectl exec -it <pod-name> -n <name-space> -- /bin/sh 	

# 查看pod的日志信息
kubectl logs <pod-name> -n <name-space> --tail <numbers> -f	

# 可以将本地的文件拷贝到pod内部, 同样也可以将pod内部的文件拷贝到matser宿主机上
kubectl cp fileName <pode-id>:<path in pod> -n <name-space>	

# 可以查看命名空间下所有的部署文件信息
kubectl get deployment -n <name-space>

# 可以修改某个pod的部署信息,修改完pod会自动被删除,然后重新拉起修改的内容自动生效
kubectl edit deployment <deployment-name> -n <name-space>	

# 手动指定pod的镜像版本
kubectl set image {镜像名} {容器名}={镜像地址}:{tag} -n {namespace}

# 查看容器的环境变量
kubectl exec {容器名} -n {namespace} -- env 
```