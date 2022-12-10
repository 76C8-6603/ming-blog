---

    title: "SwiftUI Examples"
    date: 2022-11-06
    tags: ["swift"]

---

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





