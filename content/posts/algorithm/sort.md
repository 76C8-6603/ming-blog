---

    title: "排序算法"
    date: 2017-08-09
    tags: ["algorithm"]

---

# 选择排序
* 时间复杂度 O(n<sup>2</sup>)
* 空间复杂度 O(1)

特点：交换次数小，适合于交换成本较高的排序。    
思路：遍历集合中的每个元素，并在每次遍历中从当前坐标往后查找最小值，然后替换当前元素和最小元素的坐标。  

```java
public void sort(int[] rawArray) {
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
}
```


> [动态算法](https://www.cs.usfca.edu/~galles/visualization/ComparisonSort.html)

# 插入排序
* 时间复杂度 O(n<sup>2</sup>)
* 空间复杂度 O(1)  

特点： 插入排序在接近有序，和数据量较小的排序中表现优秀。  
思路： 遍历集合中的每个元素，并把当前已经遍历过的元素排序，直到最后一个元素，完成排序。  

```java
public void sort(int[] rawArray) {
    for (int outer = 0; outer < rawArray.length; outer++) {
        int temp = rawArray[outer];
        int inner = outer;
        while (inner > 0 && rawArray[inner-1] > temp) {
            rawArray[inner] = rawArray[inner-1];
            inner--;
        }
        rawArray[inner] = temp;
    }
}
```

> [动态算法](https://www.cs.usfca.edu/~galles/visualization/ComparisonSort.html)  
> [链表插入排序](https://leetcode-cn.com/problems/insertion-sort-list/)  


# 归并排序
* 时间复杂度&nbsp;&nbsp;&nbsp; O(***N***log***N***) &nbsp;&nbsp;&nbsp;这里的N是数组的长度
* 空间复杂度&nbsp;&nbsp;&nbsp; O(***N***)  

特点： 归并排序借助了额外空间，可以实现`稳定排序`（相同的几个值在多次排序后，先后位置保持不变）。  
思路： 二分法将集合划为多份，设定最小划分量。达到最小划分量时，通过插入排序（利用插入排序小数据量排序的优势），把对应的两份数据有序化，并合并最小单位的两份数据（双指针）。剩下的划分数据处理以此类推。    

```java
public class MergeSort {

    public static final int THRESHOLD_INSERT_SORT = 7;
    
    public void sort(int[] rawArray) {
        if (rawArray.length == 0) {
            return;
        }
        int[] tempArray = new int[rawArray.length];
        mergeSort(rawArray, 0, rawArray.length - 1, tempArray);
    }

    /**
     * 归并
     * @param rawArray
     * @param leftIndex
     * @param rightIndex
     * @param tempArray
     */
    private void mergeSort(int[] rawArray, int leftIndex, int rightIndex, int[] tempArray) {
        if (rightIndex - leftIndex + 1 <= THRESHOLD_INSERT_SORT) {
            insertionSort(rawArray, leftIndex, rightIndex);
            return;
        }

        int mid = (leftIndex + rightIndex) >>> 1;

        mergeSort(rawArray, leftIndex, mid, tempArray);
        mergeSort(rawArray, mid + 1, rightIndex, tempArray);

        if (rawArray[mid] <= rawArray[mid + 1]) {
            return;
        }

        mergeSortedArray(rawArray, leftIndex, mid, rightIndex, tempArray);
    }

    /**
     * 合并有序数组
     * @param rawArray
     * @param leftIndex
     * @param mid
     * @param rightIndex
     * @param tempArray
     */
    private void mergeSortedArray(int[] rawArray, int leftIndex, int mid, int rightIndex, int[] tempArray) {
         System.arraycopy(rawArray, leftIndex, tempArray, leftIndex, rightIndex - leftIndex + 1);

        int frontIndex = leftIndex;
        int behindIndex = mid + 1;

        int curIndex = 0;
        int curTemp;

        while (frontIndex <= mid || behindIndex <= rightIndex) {
            if (frontIndex == mid + 1) {
                curTemp = tempArray[behindIndex++];
            } else if (behindIndex == rightIndex + 1) {
                curTemp = tempArray[frontIndex++];
            } else if (tempArray[frontIndex] >= tempArray[behindIndex]) {
                curTemp = tempArray[behindIndex++];
            }else {
                curTemp = tempArray[frontIndex++];
            }
            rawArray[curIndex++] = curTemp;
        }
    }

    /**
     * 插入排序
     * @param rawArray
     * @param leftIndex
     * @param rightIndex
     */
    private void insertionSort(int[] rawArray, int leftIndex, int rightIndex) {
        for (int outer = leftIndex; outer <= rightIndex; outer++) {
            int inner = outer;
            int temp = rawArray[outer];
            while (inner > leftIndex  && rawArray[inner - 1] > temp) {
                rawArray[inner] = rawArray[inner - 1];
                inner--;
            }
            rawArray[inner] = temp;
        }
    }


    public static void main(String[] args) {
        final int[] ints = {9,3,8,13,5,4,10,7,1,2,22,6};
        final MergeSort mergeSort = new MergeSort();
        mergeSort.sort(ints);
        System.out.println(Arrays.toString(ints));
    }


}
```

> [动态算法](https://www.cs.usfca.edu/~galles/visualization/ComparisonSort.html)    
> [逆序对](https://leetcode-cn.com/problems/shu-zu-zhong-de-ni-xu-dui-lcof/)  
> [计算右侧小于当前元素的个数](https://leetcode-cn.com/problems/count-of-smaller-numbers-after-self/)   



