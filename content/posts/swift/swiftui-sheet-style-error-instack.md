---
    title: "sheet style abnormal when in stack"
    date: 2023-11-18
    tags: ["swift"]
---

```swift
HStack {
    Button("Test"){
        flag = true
    }.sheet(isPresented: $flag){
    NewPage()
        .presentationDetents([.medium, .large])
        .presentationBackgroundInteraction(.automatic)
        .presentationBackground(.regularMaterial)
}
```

There will be strange changes of the style in the sheet, just change the position of `.sheet` modifier from `Button` to `HStack`:  
```swift
HStack {
    Button("Test"){
        flag = true
    }
}.sheet(isPresented: $flag){
    NewPage()
        .presentationDetents([.medium, .large])
        .presentationBackgroundInteraction(.automatic)
        .presentationBackground(.regularMaterial)
```