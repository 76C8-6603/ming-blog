---

    title: "Java parse CSV string"
    date: 2023-01-03
    tags: ["jackson"]
---

# Library
gradle:  
```
implementation("com.fasterxml.jackson.dataformat:jackson-dataformat-csv")
```
You don't need to specify the version in normally spring boot project, because your parent dependency already has it.  

# Code  
```kotlin
val schema = CsvSchema.emptySchema().withHeader()
val mapper: ObjectReader = CsvMapper().readerFor(MyEntity::class.java).with(schema)
mapper.readValues<MyEntity>(csvJson).readAll()
```

In `MyEntity`, you don't need any other annotations, just normal `fasterxml` annotations is enough:  
```kotlin
class MyEntity{
    @JsonProperty("first_string")
    var firstString: String? = null
    
    @JsonProperty("second_string")
    var secondString: String? = null
    
    @JsonProperty("third_date")
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "Asia/Shanghai")
    var thirdDate: Date? = null
}
```
