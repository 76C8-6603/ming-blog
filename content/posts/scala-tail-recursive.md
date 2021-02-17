---
    title: "Scala实现的尾递归"
    date: 2019-02-25
    tags: ["scala"]
    
---

### 最大公约数：
```scala
@tailrec
def gcd(a: Int, b: Int): Int =
  if (b == 0) a else gcd(b, a % b)
```
### 阶乘:
```scala
def factorial(n: Int): Int = {
  @tailrec
  def iter(x: Int, result: Int): Int =
    if (x == 0) result else iter(x - 1, result * x)

  iter(n, 1)
}
```

@tailrec注解可以检测当前递归方法是否满足尾递归，不满足会报编译错误