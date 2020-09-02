---
    title: "SpringBoot定时任务"
    date: 2018-08-12
    tags: ["spring"]
    
---

#### 开启定时任务
***
```java
@Configuration
@EnableScheduling
@ComponentScan(basePackages="com.myco.tasks")
public class AppConfig {
}
```
如果需要对定时任务的生命周期有其他的操作，可以实现接口`SchedulingConfigurer`
```java
 @Configuration
 @EnableScheduling
 public class AppConfig implements SchedulingConfigurer {

     @Override
     public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
         taskRegistrar.setScheduler(taskScheduler());
         taskRegistrar.addTriggerTask(
             new Runnable() {
                 public void run() {
                     myTask().work();
                 }
             },
             new CustomTrigger()
         );
     }

     @Bean(destroyMethod="shutdown")
     public Executor taskScheduler() {
         return Executors.newScheduledThreadPool(42);
     }

     @Bean
     public MyTask myTask() {
         return new MyTask();
     }
 }
```
> 详细信息参考 [@EnableScheduling注解官方API](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/scheduling/annotation/EnableScheduling.html)

#### 配置定时任务
```java
 package com.myco.tasks;
@Component
 public class MyTask {

     @Scheduled(fixedRate=1000)
     public void work() {
         // task execution logic
     }
 }
```
注解`@Scheduled`有如下参数  
* `cron` 输入cron表达式
* `fixedDelay` 在最后一个任务执行完后，下个任务开始执行的间隔时间
* `fixedRate` 最后一个任务开始执行后，下个任务开始执行的间隔时间
* `initialDelay` 第一个任务执行前的延迟时间
* `zone` 时区
> 详细信息参考 [@Scheduled注解官方API](https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/scheduling/annotation/Scheduled.html)