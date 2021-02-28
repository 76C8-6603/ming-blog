---

    title: "免费API收集"
    date: 2019-07-23
    tags: ["api"]

---

# Google翻译
```http request
GET http://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=auto&tl=zh_CN&q=hence
```
返回示例
```json
{
    "sentences": [
        {
            "trans": "因此",
            "orig": "hence",
            "backend": 10
        }
    ],
    "src": "en",
    "confidence": 1.0,
    "spell": {},
    "ld_result": {
        "srclangs": [
            "en"
        ],
        "srclangs_confidences": [
            1.0
        ],
        "extended_srclangs": [
            "en"
        ]
    }
}
```

# 微软翻译
```http request
GET http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=AFC76A66CF4F434ED080D245C30CF1E71C22959C&from=&to=zh-Hans&text=hence
```

返回示例
```xml
<string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">因此</string>
```
# 有道翻译
```http request
GET http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=hence
```
返回示例
```json
{
  "type": "EN2ZH_CN",
  "errorCode": 0,
  "elapsedTime": 1,
  "translateResult": [
    [
      {
        "src": "hence",
        "tgt": "因此"
      }
    ]
  ]
}
```