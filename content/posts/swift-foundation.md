---

    title: "Swift foundation"
    date: 2022-06-29
    tags: ["swift"]

---
> 详细基础知识参考 [swift language guide](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html)  
> build & package [swift package manager](https://www.swift.org/package-manager/)  

### `let`常量  
### `var`变量  
### `var aDouble: Double`类型申明  
### 没有隐式类型转换，类型转换需要直接申明`String(aDouble)`  
### `This is a float: \(aDouble)` 字符串插入变量  
### `"""`三个双引号可以处理跨行字符串  
```swift
let multiLineStr = """
fist line
second line
"""
```
### List
```swift
var shoppingList = ["catfish", "water", "tulips"]
shoppingList[1] = "bottle of water"
shoppingList.append("pineapple")
print(shoppingList)

let emptyArray: [String] = []
```

### Map(Dictionary)
```swift
var occupations = [
    "Malcolm": "Captain",
    "Kaylee": "Mechanic",
]
occupations["Jayne"] = "Public Relations"
print(occupations)  


let emptyDictionary: [String: Float] = [:]
```
  
dictionary的遍历  
```swift
let interstingNums = [
    "prime": [2, 3, 5, 7, 11, 13],
    "fibonacci": [1, 1, 2, 3, 5, 8],
    "square": [1, 4, 9, 16, 25, 36],
]
var largest = 0
for (_, nums) in interstingNums{
    for num in nums{
        if num > largest {
            largest = num
        }
    }
}
print(largest)
```

### for
if或for的表达式括号可以省略，结构体的大括号不能省略  
```swift
let individualScores = [75, 100, 55, 56, 120, 12]
var teamScore = 0
for score in individualScores {
    if score > 50 {
        teamScore += 3
    }else{
        teamScore += 1
    }
}
print(teamScore)
```
带index的for  
```swift
var sum = 0
for i in 0..<5 {
    sum += i
}
```
`..<`代表`[)`, `...`代表`[]`

### if
if表达式不能有任何的隐式对比，必须是完整的boolean  
if表达式可以配合`?`符号使用  
```swift
var optionalMsg: String? = "Hello"
// optionalMsg = nil
if let validMsg = optionalMsg{
    print(validMsg)
}
```
当`optionalMsg = nil`时，if不会执行代码块  

### 非空(nil)编译检测  
```swift
var nickName: String? = nil
var fullName = "Jackie Chen"
print(nickName ?? fullName)

if let nickName {
    print("Hi, \(nickName)")
}
```
`??`类似三元表达式，如果nickName是`nil`那么就取fullname  
可以通过`if let nickName`快速拆包  

### switch
```swift
let vegetable = "red pepper"
switch vegetable {
case "celery":
    print("Add some raisins and make ants on a log.")
case "cucumber", "watercress":
    print("That would make a good tea sandwich.")
case let x where x.hasSuffix("pepper"):
    print("Is it a spicy \(x)?")
default:
    print("Everything tastes good in soup.")
}
```

### while
```swift
var n = 2
while n <= 100 {
    n *= 2
}
print(n)

//放在最后能保证循环体至少执行一次
var m = 2
repeat{
    m *= 2
}while m <= 100
print(m)
```

### 方法
```swift
func greeting(name: String, day: String) -> String{
    return "Hello \(name), today is \(day)"
}
```
`->`后面跟的就是返回结果的类型  

方法还可以为参数添加别名  
```swift
func greet(_ person: String, on day: String) -> String {
    return "Hello \(person), today is \(day)."
}
greet("John", on: "Wednesday")
```
注意上面的方法调用，必须按照添加别名后的方式调用，否则编译错误  

#### Nested Function
```swift
func returnFifteen() -> Int{
    var num = 10
    func addFive(){
        num += 5
    }
    addFive()
    return num
}

print(returnFifteen())
```
Nested Function可以访问外部方法的参数

#### return 方法
```swift
func makeIncrementer() -> ((Int) -> Int){
    func addOne(num: Int) -> Int{
        return 1 + num
    }
    return addOne
}
let addOneFun = makeIncrementer()
print(addOneFun(7))
```

#### arguments 方法
```swift
func hasAnyMatches(nums: [Int], condition: (Int) -> Bool) -> Bool{
    for num in nums{
        if(condition(num)){
            return true
        }
    }
    return false
}

func lessThanTen(num: Int) -> Bool{
    return num < 10
}

let anyMatches = hasAnyMatches(nums: [20,30,5,90], condition: lessThanTen)
print(anyMatches)
```

### Tuple 元组
```swift
func calculateStatistics(scores: [Int]) -> (max: Int, min: Int, sum: Int){
    var max = scores[0];
    var min = scores[0];
    var sum = 0;
    for score in scores{
        if score >= max {
            max = score
        }else if score < min {
            min = score
        }
        sum += score
    }
    return(max, min, sum)
}

let tupleCase = calculateStatistics(scores: [1,6,34,99,55,100])
print(tupleCase.sum)
print(tupleCase.0)
```
元组可以返回多个不同类型的数据，可以通过key访问，也可以通过index访问

### Closure 闭包
```swift
var mapNums = nums.map({(number: Int) -> Int in
    return number * 3
})
```
要用一个`in`区分代码体和闭包签名  

上面的闭包可以简写：  
```swift
var mappedNums = nums.map({num in num * 3})
```
这样简写的前提是，参数和返回值都是能够推断的，并且闭包的代码体只有一行  

闭包还可以通过参数index简写：  
```swift
// 倒序排nums，并替换原列表
nums.sort{ $0 > $1 }

//倒序排nums，返回新列表
var mappedNums = nums.sorted{ $0 > $1 }
```
如果闭包是函数的唯一一个参数（像上面的例子），那么可以把括号省略了。  
如果闭包是函数最后一个参数，可以直接在函数括号后直接声明闭包。  

### Class  
#### 基础类：
```swift
class Shape{
    var numberOfSides = 0
    
    func description() -> String{
        return "Shape with \(numberOfSides) sides"
    }
}

var shape = Shape()
shape.numberOfSides = 5

print(shape.description())
```  

#### 构造方法类：  
```swift
class NamedShape{
    var numberOfSlides = 0
    var name:String
    init(name: String){
        self.name = name
    }
    func description() -> String{
        return "\(name) Shape with \(numberOfSlides) slides"
    }
}

var namedShape = NamedShape(name: "Square")
namedShape.numberOfSlides = 4
print(namedShape.description())
```
方法内的成员变量都需要初始化，要么声明时赋值，要么通过`init`构造方法赋值。  
`deinit`方法可以处理对象前执行一些清理操作。  

#### 类继承：  
```swift
class Square: NamedShape{
    var sideLength: Double
    
    init(sideLength: Double, name: String){
        self.sideLength = sideLength
        super.init(name: name)
        super.numberOfSlides = 4
    }
    
    func area() -> Double{
        return sideLength * sideLength
    }
    
    override func description() -> String {
        return "Square sideLength: \(sideLength), area: \(area())"
    }
}

var square = Square(sideLength: 6.6, name: "66 Square")
print(square.description())
```
子类没有限制，可以继承也可以不继承，重写的方法必须标注`override`  

#### Getter/Setter
```swift
class EqualateralTrangle: NamedShape{
    var sideLength: Double = 0.0
    
    init(sideLength: Double, name: String){
        self.sideLength = sideLength
        super.init(name: name)
        super.numberOfSlides = 3
    }
    
    var perimeter: Double {
        get{
            sideLength * 3
        }
        set{
            sideLength = newValue / 3
        }
    }
    
    override func description() -> String {
        return "EqualateralTrangle sideLength: \(sideLength), perimeter: \(perimeter)"
    }
}

var trangle = EqualateralTrangle(sideLength: 3, name: "Trangle")
print(trangle.description())
trangle.perimeter = 15
print(trangle.description())
```
set省略了参数声明，可以手动添加`set(newValue)`  

#### willSet/didSet
在set执行之前和之后调用 `willSet`和`didSet`  
```swift
class TrangleAndSquare{
    var trangle: EqualateralTrangle {
        willSet{
            square.sideLength = newValue.sideLength
        }
    }
    
    var square: Square{
        willSet{
            trangle.sideLength = newValue.sideLength
        }
    }
    
    init(sideLength: Double, name: String){
        self.trangle = EqualateralTrangle(sideLength: sideLength, name: name)
        self.square = Square(sideLength: sideLength, name: name)
    }
}

var tAndS = TrangleAndSquare(sideLength: 5, name: "Test")
print(tAndS.square.description())
print(tAndS.trangle.description())

tAndS.trangle = EqualateralTrangle(sideLength: 9, name: "New")
print(tAndS.square.description())
print(tAndS.trangle.description())
```
willSet跟一般的set一样，有一个默认的参数`newValue`，但是didSet没有  

```swift
var optionalSquare:Square? = Square(sideLength: 2.5, name: "Optional")
var length = optionalSquare?.sideLength
```
`?`代表`optional value`，在执行调用的时候，如果对象为空，那么问号后面的调用不会执行，表达式会返回`nil`。  
`optional`语句返回的也是`optional value`，第二句完整的参数申明是`var length: Double?`。  

### Enumeration  
```swift
enum Rank: Int{
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king
    
    func simpleDesc() -> String{
        switch self{
        case .ace:
            return "Ace"
        case .jack:
            return "Jack"
        case .queen:
            return "Queen"
        case .king:
            return "King"
        default:
            return String(self.rawValue)
            
        }
    }
}

// 11 test
print("\(Rank.jack.rawValue) test")

//jack test
print("\(Rank.jack) test")
```
枚举的声明如上面的例子所示。需要注意几个地方：  
1. 枚举如果需要替代值，那么值的类型必须在枚举名称后声明`enum Rank: Int`  
2. 替代值如果为`Int`，那么默认会为其赋值，从零开始递增。也可以手动指定起始值，只需要为第一个`case`赋值即可，比如上面的`case ace = 1`  
3. 如果替代值不是`Int`，那么必须为每个枚举成员变量赋值  
4. 获取替代值，通过`rawValue`参数获取，如上`Rank.jack.rawValue`  
5. 获取`case`命名， 直接获取即可，如上`Rank.jack`  
6. switch`.ace`是一种缩写，根据上下文是已经知道类的情况下的简写。如果引用申明了类型，也可以这样写`var jack: Rank = .jack`  
7. 如果枚举没必要声明`rawValue`，那么可以直接省略掉  

枚举有默认的构造方法，可以用来解析`rawValue`  
```swift
var optionalRank = Rank(rawValue: 13)
if let rank = optionalRank{
    print(rank.simpleDesc())
}
```
`init?(rawValue:)`该构造方法返回的是`optional value`  

上面的枚举类型，都是定值枚举，`rawValue`在一个枚举实例中只能有一个值，比如`Rank.ace`实例中，`rawValue`只能为`1`  
还有一种情况，`rawValue`可以与case绑定，也就是说在一个枚举实例中，`rawValue`根据case的不同，有不同的值  
```swift
enum ResponseBody{
    case success(String, String)
    case fail(String)
}

let success = ResponseBody.success("200", "Things you what")
let fail = ResponseBody.fail("Shit")

switch success {
case let .success(msg, body):
    print("Success, msg: \(msg), body:\(body)")
case let .fail(msg):
    print("Fail, msg:\(msg)")
}
```
注意`switch case`语句中的`let`  

### Struct
`struct`跟`class`使用规则上大体都相同，不同的在于他们的数据结构，`struct`占用的是栈内存，`class`占用的堆内存，引用官网的描述：  
> One of the most important differences between structures and classes is that structures are always copied when they’re passed around in your code, but classes are passed by reference.  

```swift
struct Card {
    var rank: Rank
    var suit: Suit
    func simpleDescription() -> String {
        return "The \(rank.simpleDescription()) of \(suit.simpleDescription())"
    }
}
let threeOfSpades = Card(rank: .three, suit: .spades)
let threeOfSpadesDescription = threeOfSpades.simpleDescription()
```  

### Concurrency
```swift
func fetchUserID(from server: String) async -> Int {
    if server == "primary" {
        return 97
    }
    return 501
}

func fetchUsername(from server: String) async -> String {
    let userID = await fetchUserID(from: server)
    if userID == 501 {
        return "John Appleseed"
    }
    return "Guest"
}

func connectUser(to server: String) async {
    async let userID = fetchUserID(from: server)
    async let username = fetchUsername(from: server)
    let greeting = await "Hello \(username), user ID \(userID)"
    print(greeting)
}

Task {
    await connectUser(to: "primary")
}
```
需要注意的点：
1. `async`标记方法会让方法异步运行    
2. `await`需要在调用异步方法时标记，代表阻塞调用  
3. `async`放在语句开头，代表该调用异步非阻塞  
4. 在需要使用异步方法返回的值时，需要使用`await`，例如`connectUser`中的例子  
5. `async let userID = ... ` 必须申明为`let`  
6. 在同步代码中调用异步逻辑，用`Task`包裹。  

### Protocol  
跟接口概念类似  
```swift
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}
```
`class` `struct` `enum`都可以实现`protocol`  
```swift
class SimpleClass: SimpleProtocol{
    var simpleDiscription: String = "Part"
    func adjust() {
        simpleDiscription += " Completed"
    }
}

var simpleClass = SimpleClass()
simpleClass.adjust()
print(simpleClass.simpleDiscription)

struct SimpleStruct: SimpleProtocol{
    var simpleDiscription: String = "Part"
    
    mutating func adjust() {
        simpleDiscription += " Completed"
    }
}
var simpleStruct = SimpleStruct()
simpleStruct.adjust()
print(simpleStruct.simpleDiscription)
```
注意`mutating`标识该方法会修改当前类，上面的例子中`protocol`和`struct`里面的方法都有使用，但是`class`不用申明，因为在其内的方法始终可以修改当前类  


### Extension
`extension`很强大，可以扩展已存在的type，包括在封包中的type  
```swift
extension Int: SimpleProtocol{
    var simpleDiscription: String{
        return "The number \(self)"
    }
    mutating func adjust() {
        self += 5
    }
}

var num = 5
print(num.simpleDiscription)
num.adjust()
print(num)
```
上面的例子扩展了`Int`，让其实现了`SimpleProtocl`，添加了一个新属性和新方法，之后可以通过`Int`实例直接调用  
注意`extension`中如果方法会改变当前的type，也要声明`mutating`  

多态的实现跟Java类似  
```swift
let simpleProtocol: SimpleProtocol = simpleClass
print(simpleProtocol.simpleDiscription)
```
同样向上造型的对象只能访问抽象的方法和属性，任何实现类的属性和方法都是不能访问的（可以通过extension)  

### Error Handling  
异常类可以通过实现`Error` protocol来声明
```swift
enum PrinterError: Error {
    case outOfPaper
    case noToner
    case onFire
}
```
抛异常的方式跟Java类似  
```swift
func send(job: Int, toPrinter printerName: String) throws -> String {
    if printerName == "Never Has Toner" {
        throw PrinterError.noToner
    }
    return "Job sent"
}
```  
方法需要声明 `throws`但不用写明具体异常。  

可以通过`do..catch`来处理异常  
```swift
do {
    let printerResponse = try send(job: 1040, toPrinter: "Never Has Toner")
    print(printerResponse)
} catch {
    print(error)
}
```
记得调用可能抛出异常的方法时，要加上前缀`try`  

catch也可以申明多次，跟Java的逻辑一样  
```swift
do {
    let printerResponse = try send(job: 1440, toPrinter: "Gutenberg")
    print(printerResponse)
} catch PrinterError.onFire {
    print("I'll just put this over here, with the rest of the fire.")
} catch let printerError as PrinterError {
    print("Printer error: \(printerError).")
} catch {
    print(error)
}
// Prints "Job sent"
```  

另外一种异常处理方法，是Optional  
```swift
let printerSuccess = try? send(job: 1884, toPrinter: "Mergenthaler")
let printerFailure = try? send(job: 1885, toPrinter: "Never Has Toner")
```
`try?`会覆盖掉异常信息，如果抛异常直接返回`Nil`。正常返回Optional value  

`defer`模块跟Java finally类似，不管方法是否抛出异常，都会在return之前调用  
```swift
var fridgeIsOpen = false
let fridgeContent = ["milk", "eggs", "leftovers"]

func fridgeContains(_ food: String) -> Bool {
    fridgeIsOpen = true
    defer {
        fridgeIsOpen = false
    }

    let result = fridgeContent.contains(food)
    return result
}
fridgeContains("banana")
print(fridgeIsOpen)
// Prints "false"
```
`defer`模块可以申明在方法中的任何地方，但是要注意，如果异常抛出先于`defer`模块，那么`defer`不会执行。另外就算把`defer`放到第一行，它也会在最后执行。  

### Generics
范性的使用也跟Java类似  
```swift
func makeArray<Item>(repeating item: Item, numberOfTimes: Int) -> [Item] {
    var result: [Item] = []
    for _ in 0..<numberOfTimes {
        result.append(item)
    }
    return result
}
makeArray(repeating: "knock", numberOfTimes: 4)
```

除了方法，范性当然也可以作用在type上  
```swift
// Reimplement the Swift standard library's optional type
enum OptionalValue<Wrapped> {
    case none
    case some(Wrapped)
}
var possibleInteger: OptionalValue<Int> = .none
possibleInteger = .some(100)
```  

可以用`where`给范性提供一些约束， 比如必须实现某个protocol，两个参数类型必须一样，或者类必须指定某个父类  
```swift
func anyCommonElements<T: Sequence, U: Sequence>(_ lhs: T, _ rhs: U) -> Bool
    where T.Element: Equatable, T.Element == U.Element
{
    for lhsItem in lhs {
        for rhsItem in rhs {
            if lhsItem == rhsItem {
                return true
            }
        }
    }
    return false
}
anyCommonElements([1, 2, 3], [3])
```
Writing <T: Equatable> is the same as writing <T> ... where T: Equatable.





















