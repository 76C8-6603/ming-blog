---
    title: "Create ML Model predicts multiple results"
    date: 2024-01-14
    tags: ["AI", "swift"]
---

```swift
import CoreML
import NaturalLanguage

struct ModelTool {

    private static var defaultModelClassifier: ModelClassifier {
        do {
            return try ModelClassifier(configuration: .init())
        } catch {
            fatalError("Couldn't load ModelClassifier due to: \(error.localizedDescription)")
        }
    }

    static func predictLabelFor(_ value: String) -> [String]? {
        let rawModel = defaultModelClassifier.model
        var nlModel:NLModel? = try? NLModel(mlModel: rawModel)
        
        // it will return 11 results
        let rawResults: [String : Double]? = nlModel?.predictedLabelHypotheses(for: value, maximumCount: 11)
        
        // return the key list and sorted by precision
        return rawResults?.sorted{ $0.value > $1.value }.map({ (key: String, value: Double) in
            return key
        })
    }
    
}
```