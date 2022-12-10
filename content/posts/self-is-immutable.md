---

    title: "Cannot assign to property: 'self' is immutable"
    date: 2022-12-10
    tags: ["swift"]

---

```swift
struct Test{
    var param1 = false
    
    func method1() {
        param1 = true
    }
}
```
`param1 = true` will throw the exception `Cannot assign to property: 'self' is immutable`  

The reason is that `struct` is saved in stack memory, so its parameters cannot be modified.  
But we can change it through `mutating`:  

```swift
struct Test{
    var param1 = false
    
    mutating func method1() {
        param1 = true
    }
}
```
Refer to [stack overflow](https://stackoverflow.com/questions/49253299/cannot-assign-to-property-self-is-immutable-i-know-how-to-fix-but-needs-unde)  