---
title: "List addAll产生异常java.lang.UnsupportedOperationException"
date: 2017-11-12
tags: ["java"]

---

原因是因为list是由Arrays.asList生成的
根据Arrays源码，asList方法生成的ArrayList，并不是java.util.ArrayList，而是Arrays的一个内部类

```java
public static <T> List<T> asList(T... a) {
        return new ArrayList<>(a);
}
```
该内部类直接继承了AbstractList，并且并未实现addAll方法
```java
private static class ArrayList<E> extends AbstractList<E>
        implements RandomAccess, java.io.Serializable
```
然而默认的AbstractList的addAll方法直接抛出了异常，并未有任何实现
```java
public boolean addAll(Collection<? extends E> c) {
        boolean modified = false;
        for (E e : c)
            if (add(e))
                modified = true;
        return modified;
    }

public boolean add(E e) {
        throw new UnsupportedOperationException();
    }
```