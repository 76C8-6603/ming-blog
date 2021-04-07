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