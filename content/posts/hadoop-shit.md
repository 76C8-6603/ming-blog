---
    title: "Hadoop安装踩坑"
    date: 2019-12-16
    tags: ["hadoop"]
    
---

切记！！！！！

没有比官网教程更详细，更靠谱的教程！！！！！

其他的基本都是官网的翻译，但是官网的教程是实时更新的，要是不注意版本，坑根本就踩不完！！！

附上官网部署教程：  
https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html

$\color{#DAA520}{单节点的安装只需要关注两个点：}$  
　　1.linux安装的java版本，各个版本的hadoop对java版本是要求的，具体信息如下：
　　　　https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions

　　2.在多次执行hdfs dfs -format后，namenode和datanode的clusterid可能对不上，在format之前需要删除tmp/hadoop-hadoop目录
