---
    title: "Assert常用方法"
    date: 2016-05-17
    tags: ["test"]
    
---
## org.junit.Assert
* `assertEquals` 判断对象是否相等，equals方法判断
* `assertSame` 判断对象是否相等，==判断
* `assertTrue` 判断条件是否为真
* `assertFalse` 判断条件是否为假
* `assertNotNull` 判断对象是否不为null
* `assertArrayEquals` 判断数组是否相等


## org.skyscreamer.jsonassert.JSONAssert
JSONAssert可对json进行断言
* 判断两个JSON对象 assertEquals(...boolean strict) 字段顺序不影响结果。当strict为false时，一个json是另外一个json的子集也能通过(比如{"id":1}和{"id":1,"name":"赵四"})
* 判断两个JSON数组 assertEquals(...boolean strict) 所有子元素必须全匹配，strict为false时，可以忽略数组顺序


## AssertJ
`AssertJ`是一个强大的链式结构的断言，一段代码可以进行多个断言。下面是一个官方实例：
```java
// entry point for all assertThat methods and utility methods (e.g. entry)
import static org.assertj.core.api.Assertions.*;

// basic assertions
assertThat(frodo.getName()).isEqualTo("Frodo");
assertThat(frodo).isNotEqualTo(sauron);

// chaining string specific assertions
assertThat(frodo.getName()).startsWith("Fro")
                           .endsWith("do")
                           .isEqualToIgnoringCase("frodo");

// collection specific assertions (there are plenty more)
// in the examples below fellowshipOfTheRing is a List<TolkienCharacter>
assertThat(fellowshipOfTheRing).hasSize(9)
                               .contains(frodo, sam)
                               .doesNotContain(sauron);

// as() is used to describe the test and will be shown before the error message
assertThat(frodo.getAge()).as("check %s's age", frodo.getName()).isEqualTo(33);

// exception assertion, standard style ...
assertThatThrownBy(() -> { throw new Exception("boom!"); }).hasMessage("boom!");
// ... or BDD style
Throwable thrown = catchThrowable(() -> { throw new Exception("boom!"); });
assertThat(thrown).hasMessageContaining("boom");

// using the 'extracting' feature to check fellowshipOfTheRing character's names
assertThat(fellowshipOfTheRing).extracting(TolkienCharacter::getName)
                               .doesNotContain("Sauron", "Elrond");

// extracting multiple values at once grouped in tuples
assertThat(fellowshipOfTheRing).extracting("name", "age", "race.name")
                               .contains(tuple("Boromir", 37, "Man"),
                                         tuple("Sam", 38, "Hobbit"),
                                         tuple("Legolas", 1000, "Elf"));

// filtering a collection before asserting
assertThat(fellowshipOfTheRing).filteredOn(character -> character.getName().contains("o"))
                               .containsOnly(aragorn, frodo, legolas, boromir);

// combining filtering and extraction (yes we can)
assertThat(fellowshipOfTheRing).filteredOn(character -> character.getName().contains("o"))
                               .containsOnly(aragorn, frodo, legolas, boromir)
                               .extracting(character -> character.getRace().getName())
                               .contains("Hobbit", "Elf", "Man");

// and many more assertions: iterable, stream, array, map, dates, path, file, numbers, predicate, optional ...
```
AssertJ的语法比较简单，通过ide提示基本都能找到目标断言，更多可以参考[AssertJ官方文档](https://assertj.github.io/doc/#assertj-overview) 和 [AssertJ java doc](https://www.javadoc.io/doc/org.assertj/assertj-core)