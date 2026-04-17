pipeline {
    agent any
    stages {
        stage('Clone Code') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo 'Building with Maven...'
                sh 'cd myapp && mvn clean package'
            }
        }
    }
}
