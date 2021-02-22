---

    title: "Junit5常用注解"
    date: 2018-11-13
    tags: ["junit5"]

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