pipeline {
    agent {docker:'hugo'}
    stages {
        stage('Test') {
            steps {
                sh './mvnw clean'
            }
        }
    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}