---

    title: "Standford npl 使用说明"
    date: 2021-03-04
    tags: ["npl"]

---

# 实例
下面是两个简单的实例，目的是获取一个单词的词根，并自动识别大小写。一个使用的是`SimpleCoreNLP`API简单实现，另外一个是通过完整的Pipeline来实现。

## SimpleCoreNPL
```java
//直接获取一个单词的词根，但是此方法不会自动识别大小写
String tokenLemma = new Sentence("Cyberpunk").lemma(0);

//直接获取一个单词的词根，并且识别大小写
Properties properties = PropertiesUtils.asProperties(
        "language", "english",
        "ssplit.isOneSentence", "true",
        "tokenize.class", "PTBTokenizer",
        "tokenize.language", "en",
        "mention.type", "dep",
        "coref.mode", "statistical",  
        "coref.md.type", "dep",
        //这个属性实现了自动识别大小写，删掉这个属性就跟上面方法完全一样
        "truecase.overwriteText","true"
        );
List<String> matting = new Sentence("Has").lemmas(properties);
```

## Pipeline
```java
Properties properties = PropertiesUtils.asProperties("annotators", "tokenize,ssplit,pos,lemma,truecase");
StanfordCoreNLP pipeline = new StanfordCoreNLP(properties);

Annotation tokenAnnotation = new Annotation("Has have HAVE");
pipeline.annotate(tokenAnnotation);  
List<CoreMap> list = tokenAnnotation.get(SentencesAnnotation.class);
pipeline.prettyPrint(tokenAnnotation,System.out);
```
上面的例子可以对整句话进行解析，最后打印的结果是其中每个单词的分析结果。分析结果的格式是每个属性都对应了一个结果，比如lemma词根对应一个结果，truecase大小写对应一个结果，可以直接获取，也可以进行重写合并等操作，具体不展开，参考官方文档。  

> 关于更多可用属性，可以参考[all annotator](https://stanfordnlp.github.io/CoreNLP/annotators.html)