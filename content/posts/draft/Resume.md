
### **项目经历**
***
#### 1. 交互式探索项目
***
2015/12 - 2016/12 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**交互式探索项目**
#### 项目简介
***
* 数据挖掘项目，覆盖一个从未加工数据到意向图表的完整流程

#### 技术栈
***
* Struts2 + Spring + iBatis
* Oracle、Mysql、Gbase

#### 工作内容
***
1. 基于AOP的敏感操作日志，例如登录，数据导出，数据源创建和删除，和数据脱敏等操作
2. 系统漏洞处理，诸如文件上传漏洞，sql注入漏洞，struts2漏洞
3. 省市地区特有功能开发，多版本维护，svn完整迁移到git
4. 多数据源配置，按业务分库分表
5. 现场功能维护，基于java assist和java agent的零侵入日志打印、数据统计、和参数调整等等。

#### 问题难点
***
1. 代码老，维护人员更换频繁，注释不完整

个人简介
我阅读的书籍：《大话设计模式》、《深入分析Java Web技术内幕》、《设计模式》、《重构》等书籍
我的技术博客：https://www.cnblogs.com/wanshiming/
项目经验：
工作经历：
教育背景：
专业技能：
1.熟悉设计模式，反射机制，了解java新特性，有良好的面对对象编程思想。
2.熟悉spring框架，并了解其运行机制。
3.mvc架构熟悉，并掌握spring mvc，了解strust2
4.orm框架熟悉ibatis ，并明白其运行机制，了解jpa
5.spring boot


工作经历																							
2015.12-2018.9   		北京东方国信科技股份有限公司		JAVA程序开发
	客户细分项目					Java7，SpringMVC+Spring+iBatis，MySql，Jenkins+Docker，ANT，GIT
	探索式数据分析应用平台（EVAP）	Java7，Struts2+Spring+iBatis，Oracle，ANT，SVN
	Bitwd交互项目（EVAP项目重构）	Java8，Spring Boot+JPA，MySql，Jenkins+Docker，MAVEN，GIT

项目经验


	静态化后端和前端JSP开发
1）由于客户细分项目需要集成到一个大型平台当中，各个项目原本的用户信息不同，因此用户部门信息统一从Nginx缓存获取，并剔除前台页面的用户信息。
2）项目将公共数据集缓存在Nginx中，各项目处理公共数据，直接读取缓存，加快页面响应速度。

	数据库读写分离和列式储存
1）由于用户增删改业务字段频繁，并且主要业务查询的目标数据量大，因此利用数据库的主从热备功能进行了读写分离。
2）随着用户业务信息的不断扩展，SQL越来越复杂，响应变慢，所以继续提取了业务主要查询信息到列式数据库。

	去数据库依赖，由于客户细分项目部署在多个省市的服务器，数据库服务器地址不同，根据现场情况，数据库产品也不同，独立的数据库连接模块、规范化的SQL以及抽象工厂架构的SQL模块，大大的提高了开发效率。

	完整规范的接口文档撰写，因为是多个部门的协作开发，完整规范的接口说明文档就尤其重要。

	Quartz定时并发导出excel功能模块开发，excel生成基于poi开源组件。

	项目重构准备，有效代码通过门面模式集中整合，提取封装为jar包。

	项目重构经验，自学设计模式相关知识，了解Java8新特性，使用函数式编程，基于Spring Boot + JPA框架完成开发。