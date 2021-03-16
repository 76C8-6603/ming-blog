---

    title: "Redis数据类型"
    date: 2019-12-08
    tags: ["redis"]
    draft: true
---

# String
二进制安全的String，意味着String可以是任何内容，包括一个文件的二进制编码。  
Key值作为String类型，最大长度是512MB。按照官网的说明，最好是为key值加上schema，比如`user:1000`。如果key值有多个单词的时候，用`.`或者`-`线分隔，比如`comment:1234:reply-to`

# List
String的有序集合，根据插入顺序排序。底层基于`linked list`。  

# Set
String的无序集合，保证成员你的唯一性。

# Sorted Set
String的有序集合，每个string元素都跟一个浮点值（score）关联。元素始终根据他们的score排序，因此可以请求一个范围的元素，比如top n，或者bottom n。

# Hash
有键值对组成，key和value都是string。跟Ruby和Python的hash类似。

# Bitmap
Bitmap又叫Bit array。可以使用特殊命令来处理字符串值，就像位数组一样：可以设置和清除单个位，对所有设置为1的位进行计数，找到第一个设置或未设置的位，依此类推。

# HyperLogLog
这是一个概率数据结构，用于估计集合的基数。

# Stream

# Geo
地理坐标，可存储经纬度。通过类似items (latitude, longitude, name) 的语法将指定的坐标数据添加到key。数据是以一个Sorted set形式存在key中。  
> 详情参考[GEO](https://redis.io/commands/geoadd)