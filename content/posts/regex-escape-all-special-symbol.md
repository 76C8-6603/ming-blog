---
    title: "正则表达式转义所有特殊符号"
    date: 2017-05-26
    tags: ["regexp"]
    
---

正则表达式的特殊符号包括  
_\ $ ( ) * + . [ ] ? ^ { } | -_  
实现代码(java)
```java
public class RegexUtils {
    private static final String[] SPECIAL_SYMBOLS =
            new String[]{"\\", "$", "(", ")", "*", "+", ".", "[", "]", "?", "^", "{", "}", "|", "-"};
 
    /**
     * 转义目标正则表达式中的所有特殊字符
     * @param regex
     * @return
     */
    public static String escapeSpecialSymbols(String regex) {
        for (String specSymbol : SPECIAL_SYMBOLS) {
            String escapeSymbol = "\\" + specSymbol;
            regex = regex.replace(specSymbol, escapeSymbol);
        }
        return regex;
    }
}
```

