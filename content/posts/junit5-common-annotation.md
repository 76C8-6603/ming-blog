---

    title: "Junit5常用注解"
    date: 2018-11-13
    tags: ["test"]

---
### @BeforeAll
### @BeforeEach
### @AfterAll
### @AfterEach
### @DisplayName
自定义的展示名称
### @IndicativeSentencesGeneration(separator = " -> ", generator = DisplayNameGenerator.ReplaceUnderscores.class)
更改生成测试名称规则，根据类名和方法名生成，并可以指定替换策略，比如上面的替换下划线为空格
### @Disabled
屏蔽整个类的测试，或者单个测试方法
### @EnabledOnOs/@DisabledOnOs
根据系统启用或者弃用
### @EnabledOnJre/@DisabledOnJre/@EnabledForJreRange/@DisabledForJreRange
指定jre版本或者范围启用或者弃用
### @EnabledIfSystemProperty/@DisabledIfSystemProperty
根据JVM系统参数启用或者弃用
```java
@Test
@EnabledIfSystemProperty(named = "os.arch", matches = ".*64.*")
void onlyOn64BitArchitectures() {
    // ...
}

@Test
@DisabledIfSystemProperty(named = "ci-server", matches = "true")
void notOnCiServer() {
    // ...
}
```
### @EnabledIfEnvironmentVariable/@DisabledIfEnvironmentVariable
根据底层操作系统参数启用或者弃用
```java
@Test
@EnabledIfEnvironmentVariable(named = "ENV", matches = "staging-server")
void onlyOnStagingServer() {
    // ...
}

@Test
@DisabledIfEnvironmentVariable(named = "ENV", matches = ".*development.*")
void notOnDeveloperWorkstation() {
    // ...
}
```

### @EnabledIf/@DisabledIf
```java
@Test
@EnabledIf("customCondition")
void enabled() {
    // ...
}

@Test
@DisabledIf("customCondition")
void disabled() {
    // ...
}

boolean customCondition() {
    return true;
}
```

### @Tag
打标签跟`@Filter`配合使用

### @TestMethodOrder
指定测试方法执行顺序
```java
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@TestMethodOrder(OrderAnnotation.class)
class OrderedTestsDemo {

    @Test
    @Order(1)
    void nullValues() {
        // perform assertions against null values
    }

    @Test
    @Order(2)
    void emptyValues() {
        // perform assertions against empty values
    }

    @Test
    @Order(3)
    void validValues() {
        // perform assertions against valid values
    }

}
```

### @TestInstance(Lifecycle.PER_CLASS)
默认Junit5是一个方法对应一个实例，意思就是实例中的参数被任何方法改变也不会影响其他方法。但通过上面的注解可以将其改为一个类对应一个实例，这样可能造成实例中的参数污染，可以通过`@BeforeEach`和`@AfterEach`来解决。  
改为一个类对应一个实例，可以让`@BeforeAll` `@AfterAll`声明在非static方法上，也可以在`@Nested`集成类中声明`@BeforeAll` `@AfterAll`  

### @Nested
内部测试类

### @RepeatedTest
重复测试

### @ParameterizedTest
以给定的参数列表重复执行测试
```java
@ParameterizedTest
@ValueSource(strings = { "racecar", "radar", "able was I ere I saw elba" })
void palindromes(String candidate) {
    assertTrue(StringUtils.isPalindrome(candidate));
}
```
#### @ValueSource
测试方法只有单个参数，并且参数是以下类型：  
* short

* byte

* int

* long

* float

* double

* char

* boolean

* java.lang.String

* java.lang.Class

#### @NullSource
单个参数，并且不能是原始类型
#### @EmptySource
单个参数，并且类型是数组，集合，String，Set，Map  
注意以上类型的子类型不受支持
#### @NullAndEmptySource
`@NullSource`和`@EmptySource`的复合注解  

下面的测试方法接受了所有类型的空值
```java
@ParameterizedTest
@NullAndEmptySource
@ValueSource(strings = { " ", "   ", "\t", "\n" })
void nullEmptyAndBlankStrings(String text) {
    assertTrue(text == null || text.trim().isEmpty());
}
```

#### @EnumSource
忽略`names`枚举的所有常量都会作为参数
```java
@ParameterizedTest
@EnumSource
void testWithEnumSourceWithAutoDetection(ChronoUnit unit) {
        assertNotNull(unit);
}
```
```java
@ParameterizedTest
@EnumSource(names = { "DAYS", "HOURS" })
void testWithEnumSourceInclude(ChronoUnit unit) {
    assertTrue(EnumSet.of(ChronoUnit.DAYS, ChronoUnit.HOURS).contains(unit));
}
```
除了明确指定`names`还可以通过`mode`属性去匹配常量
```java
@ParameterizedTest
@EnumSource(mode = EXCLUDE, names = { "ERAS", "FOREVER" })
void testWithEnumSourceExclude(ChronoUnit unit) {
    assertFalse(EnumSet.of(ChronoUnit.ERAS, ChronoUnit.FOREVER).contains(unit));
}
```
```java
@ParameterizedTest
@EnumSource(mode = MATCH_ALL, names = "^.*DAYS$")
void testWithEnumSourceRegex(ChronoUnit unit) {
    assertTrue(unit.name().endsWith("DAYS"));
}
```

#### @MethodSource
```java
@ParameterizedTest
@MethodSource("stringProvider")
void testWithExplicitLocalMethodSource(String argument) {
    assertNotNull(argument);
}

static Stream<String> stringProvider() {
    return Stream.of("apple", "banana");
}
```
MethodSource如果没有明确指定方法名称，会自动定位跟当前方法名相同的工厂方法（没有参数，并返回Stream<?>）
```java
@ParameterizedTest
@MethodSource
void testWithDefaultLocalMethodSource(String argument) {
    assertNotNull(argument);
}

static Stream<String> testWithDefaultLocalMethodSource() {
    return Stream.of("apple", "banana");
}
```
下面的例子是一个原始类型的例子
```java
@ParameterizedTest
@MethodSource("range")
void testWithRangeMethodSource(int argument) {
    assertNotEquals(9, argument);
}

static IntStream range() {
    return IntStream.range(0, 20).skip(10);
}
```
上面都是一个参数的例子，下面的实例展示的是多个参数时的情况：  
```java
@ParameterizedTest
@MethodSource("stringIntAndListProvider")
void testWithMultiArgMethodSource(String str, int num, List<String> list) {
    assertEquals(5, str.length());
    assertTrue(num >=1 && num <=2);
    assertEquals(2, list.size());
}

static Stream<Arguments> stringIntAndListProvider() {
    return Stream.of(
        arguments("apple", 1, Arrays.asList("a", "b")),
        arguments("lemon", 2, Arrays.asList("x", "y"))
    );
}
```
如果引用的是外部方法，那么就需要该方法的完全限定名
```java
package example;

import java.util.stream.Stream;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

class ExternalMethodSourceDemo {

    @ParameterizedTest
    @MethodSource("example.StringsProviders#tinyStrings")
    void testWithExternalMethodSource(String tinyString) {
        // test with tiny string
    }
}

class StringsProviders {

    static Stream<String> tinyStrings() {
        return Stream.of(".", "oo", "OOO");
    }
}
```

#### @CsvSource
多个参数的另一个解决方案：  
```java
@ParameterizedTest
@CsvSource({
    "apple,         1",
    "banana,        2",
    "'lemon, lime', 0xF1"
})
void testWithCsvSource(String fruit, int rank) {
    assertNotNull(fruit);
    assertNotEquals(0, rank);
}
```
`@CsvSource`可以自定义空值的别名，下面是一些`@CsvSource`使用的具体实例

Example Input|	Resulting Argument List
---|---
@CsvSource({ "apple, banana" })|"apple", "banana"
@CsvSource({ "apple, 'lemon, lime'" })|"apple", "lemon, lime"
@CsvSource({ "apple, ''" })|"apple", ""
@CsvSource({ "apple, " })|"apple", null
@CsvSource(value = { "apple, banana, NIL" }, nullValues = "NIL")|"apple", "banana", null  

#### CsvFileSource
根据csv文件内容生成测试参数，注意任何以#开头的行都会被视作为注释  
```java
@ParameterizedTest
@CsvFileSource(resources = "/two-column.csv", numLinesToSkip = 1)
void testWithCsvFileSourceFromClasspath(String country, int reference) {
    assertNotNull(country);
    assertNotEquals(0, reference);
}

@ParameterizedTest
@CsvFileSource(files = "src/test/resources/two-column.csv", numLinesToSkip = 1)
void testWithCsvFileSourceFromFile(String country, int reference) {
    assertNotNull(country);
    assertNotEquals(0, reference);
}
```
two-column.csv
```java
Country, reference
Sweden, 1
Poland, 2
"United States of America", 3
```
跟`@CsvSource`不同，这里的分隔符是双引号，不是之前的单引号。  
这里判空的方式跟`@CsvSource`类似，并且也有`nullValues`作为控制别名。  

#### @ArgumentsSource
可以用来制定一个自定义的看，可重用的`ArgumentsProvider`注意这个注解只能修饰顶级类，或者静态的集成类。  
```java
@ParameterizedTest
@ArgumentsSource(MyArgumentsProvider.class)
void testWithArgumentsSource(String argument) {
    assertNotNull(argument);
}
```
```java
public class MyArgumentsProvider implements ArgumentsProvider {

    @Override
    public Stream<? extends Arguments> provideArguments(ExtensionContext context) {
        return Stream.of("apple", "banana").map(Arguments::of);
    }
}
```
#### 多对象映射
除了前面提到的`@MethodSource`注解可以进行自定义多对象映射意外，还可以通过`ArgumentAccessor`作为参数，然后手动映射到指定的对象：  
```java
@ParameterizedTest
@CsvSource({
    "Jane, Doe, F, 1990-05-20",
    "John, Doe, M, 1990-10-22"
})
void testWithArgumentsAccessor(ArgumentsAccessor arguments) {
    Person person = new Person(arguments.getString(0),
                               arguments.getString(1),
                               arguments.get(2, Gender.class),
                               arguments.get(3, LocalDate.class));

    if (person.getFirstName().equals("Jane")) {
        assertEquals(Gender.F, person.getGender());
    }
    else {
        assertEquals(Gender.M, person.getGender());
    }
    assertEquals("Doe", person.getLastName());
    assertEquals(1990, person.getDateOfBirth().getYear());
}
```
除了`ArgumentAccessor`以外，你还可以自定义`Aggregator`。需要通过实现`ArgumentsAggregator`接口，并且将`@AggregateWith`注解放到对应参数上。  
```java
@ParameterizedTest
@CsvSource({
    "Jane, Doe, F, 1990-05-20",
    "John, Doe, M, 1990-10-22"
})
void testWithArgumentsAggregator(@AggregateWith(PersonAggregator.class) Person person) {
    // perform assertions against person
}
```
```java
public class PersonAggregator implements ArgumentsAggregator {
    @Override
    public Person aggregateArguments(ArgumentsAccessor arguments, ParameterContext context) {
        return new Person(arguments.getString(0),
                          arguments.getString(1),
                          arguments.get(2, Gender.class),
                          arguments.get(3, LocalDate.class));
    }
}
```
### @TestFactory
不同于Junit4的`@Test`，`@TestFactory`是动态的，也就是每次测试的结果可能不相同。他所修饰的方法必须返回`DynamicNode or a Stream, Collection, Iterable, Iterator, or array of DynamicNode instances`  
之所以叫`TestFactory`，就是因为他返回的是一个或者多个测试，并且他们的测试结果可能不是一定的。  
下面的例子中，第一个是错误示范，返回的不是`@TestFactory`指定的返回类型会在运行时报错。之后的五个是对可能的返回类型的展示。最后几个就是真正的动态实例。
```java
import static example.util.StringUtils.isPalindrome;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.DynamicContainer.dynamicContainer;
import static org.junit.jupiter.api.DynamicTest.dynamicTest;

import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.function.Function;
import java.util.stream.IntStream;
import java.util.stream.Stream;

import example.util.Calculator;

import org.junit.jupiter.api.DynamicNode;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.TestFactory;
import org.junit.jupiter.api.function.ThrowingConsumer;

class DynamicTestsDemo {

    private final Calculator calculator = new Calculator();

    // This will result in a JUnitException!
    @TestFactory
    List<String> dynamicTestsWithInvalidReturnType() {
        return Arrays.asList("Hello");
    }

    @TestFactory
    Collection<DynamicTest> dynamicTestsFromCollection() {
        return Arrays.asList(
            dynamicTest("1st dynamic test", () -> assertTrue(isPalindrome("madam"))),
            dynamicTest("2nd dynamic test", () -> assertEquals(4, calculator.multiply(2, 2)))
        );
    }

    @TestFactory
    Iterable<DynamicTest> dynamicTestsFromIterable() {
        return Arrays.asList(
            dynamicTest("3rd dynamic test", () -> assertTrue(isPalindrome("madam"))),
            dynamicTest("4th dynamic test", () -> assertEquals(4, calculator.multiply(2, 2)))
        );
    }

    @TestFactory
    Iterator<DynamicTest> dynamicTestsFromIterator() {
        return Arrays.asList(
            dynamicTest("5th dynamic test", () -> assertTrue(isPalindrome("madam"))),
            dynamicTest("6th dynamic test", () -> assertEquals(4, calculator.multiply(2, 2)))
        ).iterator();
    }

    @TestFactory
    DynamicTest[] dynamicTestsFromArray() {
        return new DynamicTest[] {
            dynamicTest("7th dynamic test", () -> assertTrue(isPalindrome("madam"))),
            dynamicTest("8th dynamic test", () -> assertEquals(4, calculator.multiply(2, 2)))
        };
    }

    @TestFactory
    Stream<DynamicTest> dynamicTestsFromStream() {
        return Stream.of("racecar", "radar", "mom", "dad")
            .map(text -> dynamicTest(text, () -> assertTrue(isPalindrome(text))));
    }

    @TestFactory
    Stream<DynamicTest> dynamicTestsFromIntStream() {
        // Generates tests for the first 10 even integers.
        return IntStream.iterate(0, n -> n + 2).limit(10)
            .mapToObj(n -> dynamicTest("test" + n, () -> assertTrue(n % 2 == 0)));
    }

    @TestFactory
    Stream<DynamicTest> generateRandomNumberOfTestsFromIterator() {

        // Generates random positive integers between 0 and 100 until
        // a number evenly divisible by 7 is encountered.
        Iterator<Integer> inputGenerator = new Iterator<Integer>() {

            Random random = new Random();
            int current;

            @Override
            public boolean hasNext() {
                current = random.nextInt(100);
                return current % 7 != 0;
            }

            @Override
            public Integer next() {
                return current;
            }
        };

        // Generates display names like: input:5, input:37, input:85, etc.
        Function<Integer, String> displayNameGenerator = (input) -> "input:" + input;

        // Executes tests based on the current input value.
        ThrowingConsumer<Integer> testExecutor = (input) -> assertTrue(input % 7 != 0);

        // Returns a stream of dynamic tests.
        return DynamicTest.stream(inputGenerator, displayNameGenerator, testExecutor);
    }

    @TestFactory
    Stream<DynamicTest> dynamicTestsFromStreamFactoryMethod() {
        // Stream of palindromes to check
        Stream<String> inputStream = Stream.of("racecar", "radar", "mom", "dad");

        // Generates display names like: racecar is a palindrome
        Function<String, String> displayNameGenerator = text -> text + " is a palindrome";

        // Executes tests based on the current input value.
        ThrowingConsumer<String> testExecutor = text -> assertTrue(isPalindrome(text));

        // Returns a stream of dynamic tests.
        return DynamicTest.stream(inputStream, displayNameGenerator, testExecutor);
    }

    @TestFactory
    Stream<DynamicNode> dynamicTestsWithContainers() {
        return Stream.of("A", "B", "C")
            .map(input -> dynamicContainer("Container " + input, Stream.of(
                dynamicTest("not null", () -> assertNotNull(input)),
                dynamicContainer("properties", Stream.of(
                    dynamicTest("length > 0", () -> assertTrue(input.length() > 0)),
                    dynamicTest("not empty", () -> assertFalse(input.isEmpty()))
                ))
            )));
    }

    @TestFactory
    DynamicNode dynamicNodeSingleTest() {
        return dynamicTest("'pop' is a palindrome", () -> assertTrue(isPalindrome("pop")));
    }

    @TestFactory
    DynamicNode dynamicNodeSingleContainer() {
        return dynamicContainer("palindromes",
            Stream.of("racecar", "radar", "mom", "dad")
                .map(text -> dynamicTest(text, () -> assertTrue(isPalindrome(text)))
        ));
    }

}
```
动态测试还可以根据`java.net.URI`提供的资源生成：  
* `DynamicTest.dynamicTest(String, URI, Executable)`
* `DynamicContainer.dynamicContainer(String, URI, Stream)`  

这里的URI会被转为以下`TestSource`实现：  
* `ClasspathResourceSource`  
If the URI contains the classpath scheme — for example, classpath:/test/foo.xml?line=20,column=2.  

* `DirectorySource`  
If the URI represents a directory present in the file system.  

* `FileSource`  
If the URI represents a file present in the file system.

* `MethodSource`  
If the URI contains the method scheme and the fully qualified method name (FQMN) — for example, method:org.junit.Foo#bar(java.lang.String, java.lang.String[]). Please refer to the Javadoc for DiscoverySelectors.selectMethod(String) for the supported formats for a FQMN.

* `UriSource`  
If none of the above TestSource implementations are applicable.
  
### @Timeout

### 并发测试
> 试验功能，详情参考[parallel execution](https://junit.org/junit5/docs/current/user-guide/#writing-tests-parallel-execution)