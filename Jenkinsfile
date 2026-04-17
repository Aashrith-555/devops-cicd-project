pipeline {
    agent any
    environment {
        ACR_NAME = 'devopscicdregistry.azurecr.io'
        IMAGE_NAME = 'myapp'
        ACR_USERNAME = 'devopscicdregistry'
        ACR_PASSWORD = '5hkVeoclsVTHRVVvV38qNs8J8xX67QQlEXuTBGb6WXgiFXW4J3I4JQQJ99CDAC1i4TkEqg7NAAACAZCRrNrF'
    }
    stages {
        stage('Clone Code') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        stage('Build with Maven') {
            steps {
                echo 'Building with Maven...'
                sh 'cd myapp && mvn clean package'
            }
        }
        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }
        stage('Push to ACR') {
            steps {
                echo 'Pushing to Azure Container Registry...'
                sh 'docker login ${ACR_NAME} -u ${ACR_USERNAME} -p ${ACR_PASSWORD}'
                sh 'docker tag ${IMAGE_NAME}:latest ${ACR_NAME}/${IMAGE_NAME}:latest'
                sh 'docker push ${ACR_NAME}/${IMAGE_NAME}:latest'
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully! Image pushed to ACR.'
        }
        failure {
            echo 'Pipeline failed! Check the logs above.'
        }
    }
}
