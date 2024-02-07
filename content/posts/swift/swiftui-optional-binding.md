---
    title: "Swiftui how to pass an optioanl value to Binding"
    date: 2024-01-30
    tags: ["swift"]
---


refer to [SwiftUI Optional TextField](https://stackoverflow.com/questions/57021722/swiftui-optional-textfield/57041232#57041232)  

```
import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
```

then:  
```
TextField("", text: $test ?? "default value")
```