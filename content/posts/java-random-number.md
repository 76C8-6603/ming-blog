---

    title: "Java中的随机数生成API"
    date: 2018-04-13
    tags: ["java","random"]

---

# ThreadLocalRandom
Java 1.7或者之后的版本
```java
import java.util.concurrent.ThreadLocalRandom;

// nextInt is normally exclusive of the top value,
// so add 1 to make it inclusive
int randomNum = ThreadLocalRandom.current().nextInt(min, max + 1);
```

> [ThreadLocalRandom API](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/ThreadLocalRandom.html#nextInt(int,int))  

# Random
Java 1.7之前
```java
import java.util.Random;

/**
 * Returns a pseudo-random number between min and max, inclusive.
 * The difference between min and max can be at most
 * <code>Integer.MAX_VALUE - 1</code>.
 *
 * @param min Minimum value
 * @param max Maximum value.  Must be greater than min.
 * @return Integer between min and max, inclusive.
 * @see java.util.Random#nextInt(int)
 */
public static int randInt(int min, int max) {

    // NOTE: This will (intentionally) not run as written so that folks
    // copy-pasting have to think about how to initialize their
    // Random instance.  Initialization of the Random instance is outside
    // the main scope of the question, but some decent options are to have
    // a field that is initialized once and then re-used as needed or to
    // use ThreadLocalRandom (if using at least Java 1.7).
    // 
    // In particular, do NOT do 'Random rand = new Random()' here or you
    // will get not very good / not very random results.
    Random rand;

    // nextInt is normally exclusive of the top value,
    // so add 1 to make it inclusive
    int randomNum = rand.nextInt((max - min) + 1) + min;

    return randomNum;
}
```

> [Random API](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/Random.html#nextInt(int))

# Math
不推荐，容易出错
