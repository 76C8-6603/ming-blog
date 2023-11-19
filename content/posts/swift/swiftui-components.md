---

    title: "SwiftUI Components"
    date: 2022-11-06
    tags: ["swift"]

---
> refer to [Apple Documentation](https://developer.apple.com/documentation/swiftui/app-organization)  

## Text
A Text view displays read-only text.  
```swift
Text("Hamlet")
    .font(.largeTitle)
Text("by William Shakespeare")
    .font(.caption)
    .italic()
```
![img.png](/img.png)  

## Image  
```swift
HStack {
    Image(systemName: "folder.badge.plus")
    Image(systemName: "heart.circle.fill")
    Image(systemName: "alarm")
    Image("Yellow_Daisy")
        .resizable()
        .scaledToFit()
}
.symbolRenderingMode(.multicolor)
.font(.largeTitle)
```
![img.png](/img的副本.png)  

## AsyncImage
Image which from a server.  
```swift
AsyncImage(url: URL(string: "https://example.com/icon.png"))
    .frame(width: 200, height: 200)
```


## Label

```swift
Label("Favorite Books", systemImage: "books.vertical")
    .labelStyle(.titleAndIcon)
    .font(.largeTitle)
```
![img.png](/img-01.png)  

## Controls & Picker & Button
```swift
VStack {
    HStack {
        Picker("Choice", selection: $choice) {
            choiceList()
        }
        Button("OK") {
            applyChanges()
        }
    }
    .controlSize(.mini)
    HStack {
        Picker("Choice", selection: $choice) {
            choiceList()
        }
        Button("OK") {
            applyChanges()
        }
    }
    .controlSize(.large)
}
```
![img.png](/img-02.png)  

## Rectangle & Circle & RoundedRectangle
```swift
HStack {
    Rectangle()
        .foregroundColor(.blue)
    Circle()
        .foregroundColor(.orange)
    RoundedRectangle(cornerRadius: 15, style: .continuous)
        .foregroundColor(.green)
}
.aspectRatio(3.0, contentMode: .fit)
```  

![img.png](/img-03.png)

## Capsule  
```swift
Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding()
            .background(.purple.opacity(0.75), in: Capsule())
```
![img_1.png](/img-04.png)

## @ScaledMetric  
use for dynamic type size, refer to [Apply custom fonts to text](https://developer.apple.com/documentation/SwiftUI/Applying-Custom-Fonts-to-Text)  

```swift
struct KeywordBubble: View {
    let keyword: String
    let symbol: String
    @ScaledMetric(relativeTo: .title) var paddingWidth = 14.5
    var body: some View {
        Label(keyword, systemImage: symbol)
            .font(.title)
            .foregroundColor(.white)
            .padding(paddingWidth)
            .background {
                Capsule()
                    .fill(.purple.opacity(0.75))
            }
    }
}
```

## Overlay/Background
遮照  

```swift
struct CaptionedPhoto: View {
    let assetName: String
    let captionText: String
    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .overlay(alignment: .bottom) {
                Caption(text: captionText)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}

struct Caption: View {
    let text: String
    var body: some View {
        Text(text)
            .padding()
            .background(Color("TextContrast").opacity(0.75),
                        in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
            .padding()
    }
}
```  

![img.png](/img-05.png)

## Hide a view

```swift
HStack {
    Image(systemName: "train.side.rear.car")
    if longerTrain {
        Image(systemName: "train.side.middle.car")
    }
    Image(systemName: "train.side.front.car")
}
```
![img.png](/img-06.png)  

```swift
HStack {
    Image(systemName: "train.side.rear.car")
    Image(systemName: "train.side.middle.car")
        .opacity(longerTrain ? 1 : 0)
    Image(systemName: "train.side.front.car")
}
```
![img.png](/img-07.png)


## HStack / VStack / ZStack

```swift
struct EventTile: View {
    let event: Event
    let stripeHeight = 15.0
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: event.symbol)
                .font(.title)
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title)
                Text(
                    event.date,
                    format: Date.FormatStyle()
                        .day(.defaultDigits)
                        .month(.wide)
                )
                Text(event.location)
            }
        }
        .padding()
        .padding(.top, stripeHeight)
        .background {
            ZStack(alignment: .top) {
                Rectangle()
                    .opacity(0.3)
                Rectangle()
                    .frame(maxHeight: stripeHeight)
            }
            .foregroundColor(.teal)
        }
        .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}
```

![img.png](/img-08.png)

## Customize a container's spacing  

```swift
import SwiftUI

struct ScaledSpacing: View {
    @ScaledMetric var trainCarSpace = 5
    
    var body: some View {
        Text("Scaled Spacing")
        HStack(spacing:trainCarSpace) {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        TrainTrack()
    }
}
```
![img.png](/img-09.png)  

## Padding

### Default Padding
```swift
struct DefaultPadding: View {
    var body: some View {
        Text("Default Padding")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
                .padding()
                .background(Color("customBlue"))
            TrainCar(.front)
        }
        TrainTrack()
    }
}
```
![img.png](/img-10.png)  

### Edge Padding
```swift
struct PaddingSomeEdges: View {
    var body: some View {
        Text("Padding Some Edges")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
                .padding([.leading])
                .background(Color("customBlue"))
            TrainCar(.front)
        }
        TrainTrack()
    }
}
```
![img.png](/img-11.png)  

### Specific amount of padding
```swift
struct SpecificPadding: View {
    var body: some View {
        Text("Specific Padding")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
                .padding(5)
                .background(Color("customBlue"))
            TrainCar(.front)
        }
        TrainTrack()
    }
}
```
![img.png](/img-12.png)  

### Padding position
```swift
struct PaddingTheContainer: View {
    var body: some View {
        Text("Padding the Container")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
            TrainCar(.front)
        }
        .padding()
        .background(Color("customBlue"))
        TrainTrack()
    }
}
```
![img.png](/img-13.png)  

## Space  
How to create a space.

### Spacer  
```swift
struct AddingSpacer: View {
    var body: some View {
        Text("Spacer")
        HStack {
            TrainCar(.rear)
            Spacer()
            TrainCar(.middle)
            Spacer()
            TrainCar(.front)
        }
        TrainTrack()
    }
}
```

![img.png](/img-14.png)

### opacity
```swift
struct AddingPlaceholder: View {
    var body: some View {
        Text("Spacing with a Placeholder")
        HStack {
            TrainCar(.rear)
            TrainCar(.middle)
                .opacity(0)
                .background(Color("customBlue"))
            TrainCar(.front)
            
        }
        TrainTrack()
    }
}
```

![img.png](/img-15.png)

### Zstack
```swift
struct StackingPlaceholder: View {
    var body: some View {
        Text("Stacking with a Placeholder")
        HStack {
            TrainCar(.rear)
            ZStack {
                TrainCar(.middle)
                    .font(.largeTitle)
                    .opacity(0)
                    .background(Color("customBlue"))
                TrainCar(.middle)
            }
            TrainCar(.front)            
        }
        TrainTrack()
    }
}
```  

![img.png](/img-16.png)


## @Binding
指定绑定实例，当前类可以读取和修改它，但是不是这个实例的拥有者，不负责创建这个实例。在传递这个实例的时候，需要在前面加`$`
```swift
import SwiftUI

struct RecipeEditor: View {
    @Binding var config: RecipeEditorConfig
    
    var body: some View {
        NavigationStack {
            RecipeEditorForm(config: $config)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(editorTitle)
                    }
                    
                    ToolbarItem(placement: cancelButtonPlacement) {
                        Button {
                            config.cancel()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                    ToolbarItem(placement: saveButtonPlacement) {
                        Button {
                            config.done()
                        } label: {
                            Text("Save")
                        }
                    }
                }
            #if os(macOS)
                .padding()
            #endif
        }
    }
    
    private var editorTitle: String {
        config.recipe.isNew ? "Add Recipe" : "Edit Recipe"
    }
    
    private var cancelButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .cancellationAction
        #else
        .navigationBarLeading
        #endif
    }
    
    private var saveButtonPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .confirmationAction
        #else
        .navigationBarTrailing
        #endif
    }
}
```

## @State
指定绑定实例，当前类是该实例的拥有者，该实例也在当前类的生命周期内，并且该实例有任何变动，当前类会重新构建编译，引用最新的实例
```swift
import SwiftUI

struct ContentListView: View {
    @Binding var selection: Recipe.ID?
    let selectedSidebarItem: SidebarItem
    @EnvironmentObject private var recipeBox: RecipeBox
    @State private var recipeEditorConfig = RecipeEditorConfig()

    var body: some View {
        RecipeListView(selection: $selection, selectedSidebarItem: selectedSidebarItem)
            .navigationTitle(selectedSidebarItem.title)
            .toolbar {
                ToolbarItem {
                    Button {
                        recipeEditorConfig.presentAddRecipe(sidebarItem: selectedSidebarItem)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $recipeEditorConfig.isPresented,
                           onDismiss: didDismissEditor) {
                        RecipeEditor(config: $recipeEditorConfig)
                            .presentationDetents([.medium, .large])
                            .presentationBackgroundInteraction(.automatic)
                            .presentationBackground(.regularMaterial)
                    }
                }
            }
    }
    
    private func didDismissEditor() {
        if recipeEditorConfig.shouldSaveChanges {
            if recipeEditorConfig.recipe.isNew {
                selection = recipeBox.add(recipeEditorConfig.recipe)
            } else {
                recipeBox.update(recipeEditorConfig.recipe)
            }
        }
    }
}

```

## sheet

`sheet`可以用于管理弹出的表单view, 实例中有两个参数：  
1. `isPresented` 是否展示  
2. `onDismiss` 监听`isPresented`从true变为false，参数是监听方法

```swift
import SwiftUI

struct ContentListView: View {
    @Binding var selection: Recipe.ID?
    let selectedSidebarItem: SidebarItem
    @EnvironmentObject private var recipeBox: RecipeBox
    @State private var recipeEditorConfig = RecipeEditorConfig()

    var body: some View {
        RecipeListView(selection: $selection, selectedSidebarItem: selectedSidebarItem)
            .navigationTitle(selectedSidebarItem.title)
            .toolbar {
                ToolbarItem {
                    Button {  
                        recipeEditorConfig.presentAddRecipe(sidebarItem: selectedSidebarItem)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $recipeEditorConfig.isPresented,
                           onDismiss: didDismissEditor) {
                        RecipeEditor(config: $recipeEditorConfig)
                    }
                }
            }
    }
    
    private func didDismissEditor() {
        if recipeEditorConfig.shouldSaveChanges {
            if recipeEditorConfig.recipe.isNew {
                selection = recipeBox.add(recipeEditorConfig.recipe)
            } else {
                recipeBox.update(recipeEditorConfig.recipe)
            }
        }
    }
}

```

## symbolVariant  
改变符号的样式
```swift
import SwiftUI

struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5

    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= rating ? .fill : .none)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if value != rating {
                            rating = value
                        } else {
                            rating = 0
                        }
                    }
            }
        }
    }
}
```  

![img17](/img-17.png)  

## onTapGesture
根据用户的手势改变View的状态  
下面是一个星级评价页面，用户点击评级，再次点击取消评级
```swift
import SwiftUI

struct StarRating: View {
    @Binding var rating: Int
    private let maxRating = 5

    var body: some View {
        HStack {
            ForEach(1..<maxRating + 1, id: \.self) { value in
                Image(systemName: "star")
                    .symbolVariant(value <= rating ? .fill : .none)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        if value != rating {
                            rating = value
                        } else {
                            rating = 0
                        }
                    }
            }
        }
    }
}
```  

![img17](/img-17.png)  


## Slider
范围值选定轴
```swift
@State private var speed = 50.0
@State private var isEditing = false

var body: some View {
    Slider(
        value: $speed,
        in: 0...100,
        step: 5
    ) {
        Text("Speed")
    } minimumValueLabel: {
        Text("0")
    } maximumValueLabel: {
        Text("100")
    } onEditingChanged: { editing in
        isEditing = editing
    }
    Text("\(speed)")
        .foregroundColor(isEditing ? .red : .blue)
}
```

![img18](/img-19.png)  

## TextField
文本输入框

```swift
Form {
    TextField(text: $username, prompt: Text("Required")) {
        Text("Username")
    }
    SecureField(text: $password, prompt: Text("Required")) {
        Text("Password")
    }
}
```
![img.png](/img-20.png)  

```swift
@State private var username: String = ""
@FocusState private var emailFieldIsFocused: Bool = false

var body: some View {
    TextField(
        "User name (email address)",
        text: $username
    )
    .focused($emailFieldIsFocused)
    .onSubmit {
        validate(name: username)
    }
    .textInputAutocapitalization(.never)
    .disableAutocorrection(true)
    .border(.secondary)

    Text(username)
        .foregroundColor(emailFieldIsFocused ? .red : .blue)
}
```

![img.png](/img-21.png)  

format by local currency:  

```swift
TextField("",value: $money, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
                    .font(.largeTitle)
```  
![img.png](/img-22.png)


## wrappedValue
如果要读取 `@Binding` or `@State` 对象的属性，而不是返回一个绑定对象，那么就需要 `wrappedValue`

```swift
@Binding private var recipe:Recipe

RecipeDetailView(recipe: recipe)
                .navigationTitle(recipe.wrappedValue.title)
```
上面的代码向`navigationTile`方法传递了一个String  

## Custom Binding
`@State`只能绑定初始化静态值，但如果你需要的值是一个动态值，那么就需要用到自定义绑定  
```swift
import SwiftUI

struct DetailView: View {
    @Binding var recipeId: Recipe.ID?
    @EnvironmentObject private var recipeBox: RecipeBox
    @State private var showDeleteConfirmation = false
    
    private var recipe: Binding<Recipe> {
        Binding {
            if let id = recipeId {
                return recipeBox.recipe(with: id) ?? Recipe.emptyRecipe()
            } else {
                return Recipe.emptyRecipe()
            }
        } set: { updatedRecipe in
            recipeBox.update(updatedRecipe)
        }
    }
    
    ....
}
```
类中的`recipe`属性相当于 `@State private var recipe:Recipe=...`  
但是这里的`recipe`是通过`id`检索`recipeBox`得来的，所以静态初始化行不通，就需要自定义Binding。  
注意recipe返回的是`Binding`，闭包中是对`Binding`的 `get` 和 `set` 的实现。  


## Divider
分隔符  
```swift
Divider()
```
![img.png](/img-23.png)


## TabView  
底部主菜单
```swift
TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
    Text("Tab Content 1").tabItem {Label("首页", systemImage: "house")}.tag(1)
    Text("Tab Content 2").tabItem { Label("详情", systemImage: "list.bullet.rectangle.portrait.fill") }.tag(2)
    Text("Tab Content 3").tabItem { Label("新增", systemImage: "plus.circle.fill") }.tag(3)
    Text("Tab Content 4").tabItem { Label("图表", systemImage: "chart.bar.xaxis.ascending") }.tag(4)
    Text("Tab Content 5").tabItem { Label("我的", systemImage: "person") }.tag(5)
}
```

![img.png](/img-24.png)


## 获取当前时间
```swift
Text(Date(), style: .date) 
```


## DatePicker  
```swift
DatePicker(selection: .constant(date), displayedComponents:[.hourAndMinute, .date], label: { Text("日期") })
```
![img_2.png](/img_25.png)  

## Map  
[refer to](https://medium.com/@pblanesp/how-to-display-a-map-and-track-the-users-location-in-swiftui-7d288cdb747e) 

```swift
import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    
    let locationManager = CLLocationManager()
    
    @State var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900,longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
    }
}
```

## 货币输入和键盘  

```swift
TextField("",value: $money, format: .currency(code: Locale.current.currency?.identifier ?? "CNY"))
    .font(.largeTitle)
    .keyboardType(.decimalPad)
```

## 阻塞指定时间
一秒后改变状态
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    self.isFocused = true
}
```

## focused  

只有一个文本框需要自动弹出键盘  
注意`.onAppear`需要在父类层级才会在打开页面时生效，如果直接加到`TextField`需要延时(参考[SwiftUI @FocusState - how to give it initial value](https://stackoverflow.com/questions/68073919/swiftui-focusstate-how-to-give-it-initial-value) 和 [SwiftUI: How to make TextField become first responder?](https://stackoverflow.com/questions/56507839/swiftui-how-to-make-textfield-become-first-responder))
```swift
struct MyView: View {
    
    @FocusState private var isTitleTextFieldFocused: Bool

    @State private var title = ""
    
    var body: some View {
        VStack {
            TextField("Title", text: $title)
                .focused($isTitleTextFieldFocused)
        }
        .onAppear {
            self.isTitleTextFieldFocused = true
        }
        .padding()
        
    }
}
```

多个文本框需要自动弹出键盘  
```swift
struct LoginForm: View {
    enum Field: Hashable {
        case usernameField
        case passwordField
    }

    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        Form {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .usernameField)

            SecureField("Password", text: $password)
                .focused($focusedField, equals: .passwordField)

            Button("Sign In") {
                if username.isEmpty {
                    focusedField = .usernameField
                } else if password.isEmpty {
                    focusedField = .passwordField
                } else {
                    handleLogin(username, password)
                }
            }
        }
    }
}
```

## Section 改变边框颜色  
```swift
Section("AI"){
    TextField("#标签", text: $tag)
}.listRowBackground(
    RoundedRectangle(cornerRadius: 10)
    .stroke(Color(UIColor.systemTeal), lineWidth: 3)
)
```

## 系统颜色

```swift
Color(UIColor.systemTeal)
Color(UIColor.systemRed)
Color(UIColor.systemCyan)
```










