pipeline {
    agent any
    environment {
        DOCKERHUB_USERNAME = 'aashrithk'
        IMAGE_NAME = 'myapp'
        DOCKERHUB_PASSWORD = 'Ashu@1234'
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
                sh 'docker build -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest .'
            }
        }
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                sh 'docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}'
                sh 'docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest'
            }
        }
	stage('Ansible Deploy') {
            steps {
                echo 'Deploying with Ansible...'
                sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
            }
        }
        stage('Kubernetes Deploy') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
                sh 'kubectl rollout status deployment/myapp-deployment'
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed! Image pushed to Docker Hub.'
        }
        failure {
            echo 'Pipeline failed! Check the logs above.'
        }
    }
}
