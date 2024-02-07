---
    title: "AttributeGraph: cycle detected / Modifying state during view update"
    date: 2024-01-22
    tags: ["swift"]

---

In a word, the keyboard need to be closed first, before you want to make some page changes.  
Refer to [StackOverFlow](https://stackoverflow.com/questions/69653554/get-attributegraph-cycle-detected-error-when-changing-disabled-state-of-text)  

```swift
struct ContentView: View {
  @State var isDisabled = false
  @State var text = ""
  
  var body: some View {
    VStack {
      TextField("", text: $text)
        .textFieldStyle(.roundedBorder)
        .disabled(isDisabled)

      Button("Disable text field") {
        closeKeyboard()
        isDisabled = true
      }
    }
  }

  func closeKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
    )
  }
}
```