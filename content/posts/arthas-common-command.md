---

    title: "Arthas 常用命令"
    date: 2021-09-08
    tags: ["arthas"]

---

Arthas的完整依赖包下载地址：[https://github.com/alibaba/arthas/releases](https://github.com/alibaba/arthas/releases)

```shell

# 启用Arthas交互界面，进入后选择对应的java进程
java -jar arthas-boot.jar

# 查看dashboard，包括进程的内存，cpu等使用信息
dashboard

# 打印线程id为1的栈信息，id可以从dashboard获取，这里是获取线程main方法的栈信息
thread 1 | grep 'main('

# 定位阻塞线程，只支持定位synchronized
thread -b 

# 查看1000ms内，最忙的三个线程
thread -n 3 -i 1000

# 查看指定状态的线程
thread --state WAITING

# 反编译指定类。也可以反编译指定方法，也可以指定classloader
jad demo.MathGame

# 实时查看 demo.MathGame#primeFactors 方法的返回值
watch demo.MathGame primeFactors returnObj

# quit或者exit不会终止附着在目标上的Arthas进程，必须执行stop来完全终止
stop

# help
help

# Arthas快捷键列表
keymap

# Arthas版本
version

# 清屏
cls

# 查看当前会话信息
session

# 还原对类的增强调整
reset

# jvm信息
jvm

# 修改或者查看JVM系统属性，不带参数会展示所有JVM系统属性，可以通过tab自动补全
sysprop user.country CN

# 查看JVM环境变量，不该参数展示所有，支持tab补全
sysenv USER

# 查看或者修改vm参数，不带参数展示所有，支持tab补全
vmoption PrintGC true

# 查看日志信息，包括等级，文件等
logger

# 修改日志等级，name是logger中展示的属性
logger --name ROOT --level debug

# 查看没有appender的logger信息
logger --include-no-appender

# 查看JVM加载的类的信息，包括classloader和classloader hash和字段信息
sc -d -f demo.MathGame

# 查看类的静态属性
getstatic demo.MathGame random

# 类似jmap命令的heap dump功能。下面是到指定文件
heapdump /tmp/dump.hprof

# 只选择live的对象dump
heapdump --live /tmp/dump.hprof

# 查看内存中的指定对象
vmtool --action getInstances --className java.lang.String --limit 10

# 强制GC
vmtool --action forceGc

# 查看已加载类的方法信息
sm -d java.lang.String toString

# 编译代码并且输出到指定目录
mc -d /tmp/output /tmp/ClassA.java /tmp/ClassB.java

# 本地将class文件转为base64并保存，这种方法可以绕过部分服务不能上传文件的情况
base64 < Test.class > result.txt

# 可以将base64内容复制并粘贴到对应机器，保存为text，然后执行一下命令恢复
base64 -d < result.txt > Test.class

# 加载并替换指定class文件，加载一次会记录一个 retransform entry
# 注意：不允许新增 field/method；正在跑的函数，没有终止的不会生效
retransform /tmp/MathGame.class

# 查看替换的class记录
retransform -l

# 删除指定的替换，id从命令 retransform -l 中获取
retransform -d 1

# 删除所有替换
retransform --deleteAll

# 显示触发替换，前提要已经执行过加载。会加载entry中最后加入的替换（id最大）
# 如果要删除类的替换，需要删除替换，并重新执行触发
retransform --classPattern demo.MathGame

# 查看classloader信息
classloader

# 监听方法的执行时间，执行状态。
# 下面的语句代表：每五秒统计一次 MathGame类 的 primeFactors 方法的执行状态，并且保证方法的第一个参数在执行方法完毕`后`的值小于等于2
monitor -c 5 demo.MathGame primeFactors "params[0] <= 2"

# 下面的语句代表：每五秒统计一次 MathGame类 的 primeFactors 方法的执行状态，并且保证方法的第一个参数在执行方法完毕`前`的值小于等于2
monitor -b -c 5 com.test.testes.MathGame primeFactors "params[0] <= 2"

# 观察MathGame类的primeFactors方法的参数，对象属性和返回值，遍历深度为2
watch demo.MathGame primeFactors -x 2

# 打印方法内部调用路径，并统计路径上的时间开销。这里代表只有花费时间大于10ms的调用才打印
trace demo.MathGame run '#cost > 10'

# 输出方法被调用的路径。这里代表第一个参数小于0，并且只获取前两次调用
stack demo.MathGame primeFactors 'params[0]<0' -n 2

# 记录方法每次调用的入参出参
tt -t demo.MathGame primeFactors
# 解决重载
tt -t *Test print params.length==1
tt -t *Test print 'params[1] instanceof Integer'
# 指定参数值
tt -t *Test print params[0].mobile=="13989838402"

# 展示所有tt记录
tt -l

# 筛选tt列表，这里筛选参数名称
tt -s 'method.name=="primeFactors"'

# 检索指定tt记录，这里的1003是tt列表的index
tt -i 1003

# 重新触发执行tt列表中的记录
tt -i 1004 -p

# 观察指定记录的成员变量
tt -w 'target.illegalArgumentCount'  -x 1 -i 1000


```