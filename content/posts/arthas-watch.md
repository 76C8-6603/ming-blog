---

    title: "Arthas watch 详解"
    date: 2021-09-09
    tags: ["arthas"]

---

> 以下内容是[官方文档](https://arthas.aliyun.com/doc/watch.html) 的总结

### 参数：  

| 参数名称            | 参数说明                                          |
| ------------------- | ------------------------------------------------- |
| *class-pattern*     | 类名表达式匹配                                    |
| *method-pattern*    | 方法名表达式匹配                                  |
| *express*           | 观察表达式，默认值：`{params, target, returnObj}`。ognl表达式 |
| *condition-express* | 条件表达式                                        |
| [b]                 | 在**方法调用之前**观察                            |
| [e]                 | 在**方法异常之后**观察                            |
| [s]                 | 在**方法返回之后**观察                            |
| [f]                 | 在**方法结束之后**(正常返回和异常返回)观察 (默认打开，上面三个默认关闭）       |
| [E]                 | 开启正则表达式匹配，默认为通配符匹配              |
| [x:]                | 指定输出结果的属性遍历深度，默认为 1              |

### 常用实例
注意下面讲到的`方法入参`代表方法还未执行时参数的值  
`方法出参`代表方法执行后参数的值

#### 1. 观察方法出参、this对象和返回值
> 观察表达式，默认值是{params, target, returnObj}  

```shell
watch demo.MathGame primeFactors -x 2
```

#### 2. 观察方法入参
```shell
watch demo.MathGame primeFactors "{params,returnObj}" -x 2 -b
```

#### 3. 同时观察方法调用前和方法返回后
```shell
watch demo.MathGame primeFactors "{params,target,returnObj}" -x 2 -b -s -n 2
```
* 参数里-n 2，表示只执行两次
* 这里输出结果中，第一次输出的是方法调用前的观察表达式的结果，第二次输出的是方法返回后的表达式的结果
* 结果的输出顺序和事件发生的先后顺序一致，和命令中 -s -b 的顺序无关

#### 4. 条件表达式例子
```shell
watch demo.MathGame primeFactors "{params[0],target}" "params[0]<0"
```

#### 5. 观察异常信息的例子
```shell
watch demo.MathGame primeFactors "{params[0],throwExp}" -e -x 2
```
* -e表示抛出异常时才触发
* express中，表示异常信息的变量是throwExp

#### 6. 按照耗时进行过滤
```shell
watch demo.MathGame primeFactors '{params, returnObj}' '#cost>200' -x 2
```
* cost>200(单位是ms)表示只有当耗时大于200ms时才会输出，过滤掉执行时间小于200ms的调用

#### 7. 观察当前对象中的属性
```shell
watch demo.MathGame primeFactors 'target'
```
查看某一个属性
```shell
watch demo.MathGame primeFactors 'target.illegalArgumentCount'
```

#### 8. 获取类的静态字段、调用类的静态方法的例子
```shell
watch demo.MathGame * '{params,@demo.MathGame@random.nextInt(100)}' -v -n 1 -x 2
```

### 特殊实例
#### 1. 查看第一个参数
```shell
watch com.taobao.container.Test test "params[0]"
```

#### 2. 查看第一个参数的size
```shell
watch com.taobao.container.Test test "params[0].size()"
```

#### 3. 将结果按name属性投影
```shell
watch com.taobao.container.Test test "params[0].{ #this.name }"
```

#### 4. 按条件过滤
```shell
watch com.taobao.container.Test test "params[0].{? #this.name == null }" -x 2
```
```shell
watch com.taobao.container.Test test "params[0].{? #this.name != null }" -x 2
```

#### 5. 过滤后统计
```shell
watch com.taobao.container.Test test "params[0].{? #this.age > 10 }.size()" -x 2
```

#### 6. 判断字符串相等
```shell
watch com.demo.Test test 'params[0]=="xyz"'
```

#### 7. 判断Long型
```shell
watch com.demo.Test test 'params[0]==123456789L'
```

#### 8. 子表达式求值
```shell
watch com.taobao.container.Test test "params[0].{? #this.age > 10 }.size().(#this > 20 ? #this - 10 : #this + 10)" -x 2
```

#### 9. 选择第一个满足条件
```shell
watch com.taobao.container.Test test "params[0].{^ #this.name != null}" -x 2
```

#### 10. 选择最后一个满足条件
```shell
watch com.taobao.container.Test test "params[0].{$ #this.name != null}" -x 2
```

#### 11. 访问静态变量
```shell
getstatic com.alibaba.arthas.Test n 'entrySet().iterator.{? #this.key.name()=="STOP"}'
```

#### 12. 调用静态方法
```shell
watch com.taobao.container.Test test "@java.lang.Thread@currentThread()"
```
调用静态方法再调用非静态方法
```shell
watch com.taobao.container.Test test "@java.lang.Thread@currentThread().getContextClassLoader()"
```

#### 13. 匹配线程&正则多个类多个方法
```shell
trace -E 'io\.netty\.channel\.nio\.NioEventLoop|io\.netty\.util\.concurrent\.SingleThreadEventExecutor'  'select|processSelectedKeys|runAllTasks' '@Thread@currentThread().getName().contains("IO-HTTP-WORKER-IOPool")&&#cost>500'
```
