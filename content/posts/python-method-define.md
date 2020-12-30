---

    title: "Python方法定义"
    date: 2018-01-21
    tags: ["python"]

---
```python
# 一般声明
def printUser(id,name,sex,age,email,phone,group):

printUser(1,'ming','male',18,'',110,'default')
```

```python
# 默认值
def printUser(id,name,sex,age,email='',phone=110,group='default'):


printUser(1,'ming','male',18)
```

```python
# 位置参数和关键字参数
def printUser(id,name,sex,/,age,email,*,phone,group):

# 位置参数就是调用的时候直接赋值
# 关键字参数就是调用的时候通过 key=value 的形式赋值

# 斜杠之前的只能有位置参数，斜杆之后和*号之前的，可以有关键字参数或者位置参数，*号之后的只能关键字参数
printUser(1,'ming','male',18, email='@mail', phone=110, group='default')
# 关键字参数必须在位置参数之后，并且位置参数必须遵循方法声明的顺序，但是关键字参数可以任意变换顺序
printUser(1,'ming','male',18, group='default', email='@mail', phone=110)
```

```python
# 元组
def printUser(id, name, sex, *args):

printUser(1,'ming','male', 18, '@mail', 110, 'default')
```

```python
# 多个关键字参数
def printUser(id, name, sex, **kwargs):

printUser(1,'ming','male', age=18, email='@mail', phone=110, group='defalut')
```
注意`*args`和`**kwargs`可以在一起使用，但是`*args`必须在`**kwargs`前面。

```python
# 注解
# 表示参数类型和方法返回类型
def printUser(id,name,sex, age, email:str='@email', group:str='default') -> str:
```