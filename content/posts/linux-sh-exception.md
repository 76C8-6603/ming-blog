---

    title: "linux sh文件运行异常，出现异常文件结尾或者乱码字符"
    date: 2017-09-11
    tags: ["linux"]

---

```shell
vi run.sh

# 查看当前脚本格式，如果结果是:fileformat=dos，则需要改为unix
:set ff

# 更改脚本格式为unix
:set ff=unix
```