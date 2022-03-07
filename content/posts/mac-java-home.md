---

    title: "Mac JAVA-HOME"
    date: 2021-05-30
    tags: ["mac","java"]

---

```shell
vi ~/.bash_profile
```

添加下面内容：
```
export JAVA_8_HOME=`/usr/libexec/java_home -v 1.8`
export JAVA_HOME=$JAVA_8_HOME

alias jdk8="export JAVA_HOME=$JAVA_8_HOME"
```


```shell
# 更新修改
source ~/.bash_profile

# 通过别名生效
jdk8
```