---
    title: "实体类通过建造者模式创建"
    date: 2016-06-07
    tags: ["java","design pattern"]
    
---

现在可以通过`lombok`注解`@Builder`一步实现
***
### 1.调用效果
```java
public class Test{
    public static void main(String[] args){
        Student student = Student.builder().name("小明").age(15).sex("男").build();
    }
}
```
### 2.实现原理
```java
public class Student {
    private String name;
    private Integer age;
    private String sex;


    public static Builder builder() {
        return new Builder();
    }

    public Student(Builder builder) {
        this.name = builder.name;
        this.age = builder.age;
        this.sex = builder.sex;
    }


    public static class Builder{
        private String name ;
        private Integer age ;
        private String sex;

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder age(Integer age) {
            this.age = age;
            return this;
        }

        public Builder sex(String sex) {
            this.sex = sex;
            return this;
        }

        public Student build() {
            return new Student(this);
        }
    }
}
```

### 3.静态内部类
1. 静态内部类无需依赖外部类，可以独立存在
2. 多个外部类可以共享一个静态内部类
3. 普通内部类不能申明静态的方法和变量，但是静态内部类无限制


