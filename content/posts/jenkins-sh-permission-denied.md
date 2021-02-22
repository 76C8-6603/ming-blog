---

    title: "jenkins sh permission denied"
    date: 2019-08-11
    tags: ["jenkins","git"]

---
# Jenkinsfile
```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }
    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}
```

# 异常
```log
./mvnw: Permission denied
```

# 解决方案
```shell
git update-index --chmod +x mvnw 
```