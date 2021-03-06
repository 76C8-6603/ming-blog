---

    title: "Java位运算符"
    date: 2017-05-13
    tags: ["java"]

---

# 概览
位运算都是对二进制进行向左或者向右移动的操作，java中一般来说就是对`int`和`long`类型的操作（byte和short会转为int进行操作，double和float会编译错误）。  
在对二进制数进行位移操作前，会先求余，除数是位移参数，被除数是类型的总位数（比如int32位，long64位）。这代表着不会存在位移量大于总位数的情况，当位移量是总位数的倍数时，位运算符不会做任何操作。

# \<<  
`a << 5` 相当于a乘以2的五次方。  
二进制表示就是向左移动五位，左边多出的丢弃，右边不足的补0。  
注意一旦位移结果超出了位数所能表达的最大值，那么就无法得到预期结果，并且可能出现正负变化，因为第一个符号位，被后续位移的1/0覆盖

# \>>
`a >> 5` 相当于a除以2的五次方。  
二进制表示就是像右移动五位，右边多出的丢弃，左边不足的补符号位（如果是负数，就补1，追加的符号位不会影响原值）。


# \>>>
`a >>> 5` 当a为正数的时候跟`>>`运算符一样。当a为负数时，同样执行向右移动，只不过补数为0。