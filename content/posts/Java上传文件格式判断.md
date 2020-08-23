---
    title: "Java上传文件格式判断"
    date: 2019-03-25
    tags: ["java"]
    
---
判断用户上传文件的合法性仅仅通过后缀名是完全不够的，谁也不知道后缀名是否被更改，服务器保存一个不知道真实类型的文件有极大的风险。


因此需要后台进行进一步的文件类型校验，这里有两种情况：

　　1）一般的文件类型例如：jpg、png、xlsx等等是有固定文件头的，提取出用户上传文件的文件头与固定文件头进行对比，就可以得到文件的准确类型。

　　2）文本文件：txt、csv等等。文本文件具有特殊性，文本头无明显标志。但是文本文件百分百具有业务特殊性。可以在对文本进行格式验证时，判断是否为目标类型；或者通过编码校验，看文本是否正确编码，是否有乱码存在（正确编辑的文件，不可能存在乱码），有第三方插件cpdetector可以检测当前文件的编码；最后还可以通过提供文件模板，固定文本文件的头尾等方式来进行校验。

 
这里主要说明第一种情况，第二种文本情况根据业务具体环境不同，有不同的处理方式。

文件类型枚举:

```java
package com.uti.utilEnum;


public enum  FileTypeEnum {
    JPG("ffd8ffe000104a464946"),
    PNG("89504e470d0a1a0a0000"),
    GIF("47494638396126026f01"),
    TIF("49492a00227105008037"),
    BMP_1("424d228c010000000000"),//16色位图(bmp)
    BMP_2("424d8240090000000000"),//24位位图(bmp)
    BMP_3("424d8e1b030000000000"),//256色位图(bmp)
    DWG("41433130313500000000"),
    HTML("3c21444f435459504520"),
    HTM("3c21646f637479706520"),
    CSS("48544d4c207b0d0a0942"),
    JS("696b2e71623d696b2e71"),
    RTF("7b5c727466315c616e73"),
    PSD("38425053000100000000"),
    EML("46726f6d3a203d3f6762"),
    DOC("d0cf11e0a1b11ae10000"),
    VSD("d0cf11e0a1b11ae10000"),
    MDB("5374616E64617264204A"),
    PS("252150532D41646F6265"),
    PDF("255044462d312e350d0a"),
    RMVB("2e524d46000000120001"),
    RM("2e524d46000000120001"),
    FLV("464c5601050000000900"),
    F4V("464c5601050000000900"),
    MP4("00000020667479706d70"),
    MP3("49443303000000002176"),
    MPG("000001ba210001000180"),
    WMV("3026b2758e66cf11a6d9"),
    ASF("3026b2758e66cf11a6d9"),
    WAV("52494646e27807005741"),
    AVI("52494646d07d60074156"),
    MID("4d546864000000060001"),
    ZIP("504b0304140000000800"),
    RAR("526172211a0700cf9073"),
    INI("235468697320636f6e66"),
    JAR("504b03040a0000000000"),
    EXE("4d5a9000030000000400"),
    JSP("3c25402070616765206c"),
    MF("4d616e69666573742d56"),
    XML("3c3f786d6c2076657273"),
    SQL("494e5345525420494e54"),
    JAVA("7061636b616765207765"),
    BAT("406563686f206f66660d"),
    GZ("1f8b0800000000000000"),
    PROPERTIES("6c6f67346a2e726f6f74"),
    CLASS("cafebabe0000002e0041"),
    CHM("49545346030000006000"),
    MXP("04000000010000001300"),
    DOCX("504b0304140006000800"),
    WPS("d0cf11e0a1b11ae10000"),
    TORRENT("6431303a637265617465"),
    MOV("6D6F6F76"),
    WPD("FF575043"),
    DBX("CFAD12FEC5FD746F"),
    PST("2142444E"),
    QDF("AC9EBD8F"),
    PWL("E3828596"),
    RAM("2E7261FD");

    private String value = "";

    private FileTypeEnum(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
```
具体代码:
```java
   private boolean notTextFileTypeCheck(InputStream inputStream, String specifiedType) throws IOException {
        boolean fileTypeIsVaild = false;
        byte[] buffer = new byte[10];
        inputStream.read(buffer);

        //获取当前文件的真实类型
        String curfileType = getTrueFileType(bytesToHexFileTypeString(buffer));

        //指定文件类型中是否匹配当前文件类型
        if(specifiedType.toUpperCase().equals(curfileType)){
            fileTypeIsVaild = true;
        }
        return fileTypeIsVaild;
    }

    private String getTrueFileType(String s) {
        for (FileTypeEnum fileTypeEnum : FileTypeEnum.values()) {
            if (s.startsWith(fileTypeEnum.getValue())) {
                return fileTypeEnum.toString();
            }
        }
        return null;
    }

    private String bytesToHexFileTypeString(byte[] buffer) {
        StringBuilder hexFileTypeStr = new StringBuilder();
        for (byte b : buffer) {
            String hexString = Integer.toHexString(b & 0xFF);
            if (hexString.length() < 2) {
                hexFileTypeStr.append("0");
            }
            hexFileTypeStr.append(hexString);
        }
        return hexFileTypeStr.toString();
    }
```
关于为什么要&0xFF，推荐一篇文章https://www.cnblogs.com/think-in-java/p/5527389.html，加上评论更好理解，还能回顾下“原码反码补码”的知识