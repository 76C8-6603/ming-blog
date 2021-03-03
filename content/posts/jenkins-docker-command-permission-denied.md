---

    title: "Docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock"
    date: 2019-11-05
    tags: ["jenkins"]

---
# 详细异常
```log
Docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```
# 解决方案
```shell
sudo usermod -a -G docker jenkins
```
原因是jenkins用户还没有被加到docker组里面

> 参考[stackoverflow](https://stackoverflow.com/questions/47854463/docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socke)