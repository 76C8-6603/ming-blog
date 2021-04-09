---

    title: "排序算法"
    date: 2017-08-09
    tags: ["algorithm"]

---

# 选择排序
* 时间复杂度 O(n<sup>2</sup>)
* 空间复杂度 O(1)

特点：交换次数小，适合于交换成本较高的排序

> [动态算法](https://www.cs.usfca.edu/~galles/visualization/ComparisonSort.html)
```java
public static int[] sort(int[] rawArray) {
    if (rawArray.length == 0) {
        return rawArray;
    }

    for (int outer = 0; outer < rawArray.length; outer++) {
        int lowestIndex = outer;
        for (int inner = outer + 1; inner < rawArray.length; inner++) {
            if (rawArray[lowestIndex] > rawArray[inner]) {
                lowestIndex = inner;
            }
        }
        if (lowestIndex != outer) {
            int temp = rawArray[outer];
            rawArray[outer] = rawArray[lowestIndex];
            rawArray[lowestIndex] = temp;
        }

    }
    return rawArray;
}
```

# 插入排序
* 时间复杂度 O(n<sup>2</sup>)
* 空间复杂度 O(1)  

特点： 插入排序在接近有序，和数据量较小的排序中表现优秀  

> [动态算法](https://www.cs.usfca.edu/~galles/visualization/ComparisonSort.html)
```java
public int[] sort(int[] rawArray) {
    for (int outer = 0; outer < rawArray.length; outer++) {
        int temp = rawArray[outer];
        int inner = outer;
        while (inner > 0 && rawArray[inner-1] > temp) {
            rawArray[inner] = rawArray[inner-1];
            inner--;
        }
        rawArray[inner] = temp;
    }
    return rawArray;
}
```

# 归并排序
* 时间复杂度&nbsp;&nbsp;&nbsp; O(***N***log***N***) &nbsp;&nbsp;&nbsp;这里的N是数组的长度
* 空间复杂度&nbsp;&nbsp;&nbsp; O(***N***)  

特点： 归并排序借助了额外空间，可以实现`稳定排序`（相同的几个值在多次排序后，先后位置保持不变）  

