---
    title: "spark精度丢失，导致列查询为null的解决办法"
    date: 2020-04-30
    tags: ["spark"]
    
---

spark decimal列进行计算时，可能丢失精度  
在默认情况下\[spark.sql.decimalOperations.allowPrecisionLoss]配置为true，会导致精度丢失的列展示为null  

一般情况下，修改spark配置即可解决：
```properties
spark.sql.decimalOperations.allowPrecisionLoss=false
```
[参考官方说明](https://issues.apache.org/jira/browse/SPARK-27089?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&focusedCommentId=16787374#comment-16787374)  

但是在如下例子中还会出现结果列为null的情况：
```sql
 IF(column1 IS NULL,0,column1) - IF(column2 IS NULL,0,column2)
```
去掉IF判断，就能正常获取结果

