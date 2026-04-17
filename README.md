# First step: Configurations
## devops-cicd-project
Full CI/CD pipeline using Jenkins, Docker, Ansible, K8s on Azure

## Setting up the tools using the script setup.sh from the following commands in a linux environment
1. git clone https://github.com/"YourGitHubUsername"/devops-cicd-project.git
2. cd devops-cicd-project
3. ./setup.sh

## Use following commands to push the updated code into git everytime you edit
1. cd ~/devops-cicd-project
2. git add setup.sh
3. git commit -m "Update for the session"
4. git push origin main

## Note:
Everytime while pushing the file into main branch the OS asks for Personal Access Token (PAT) as password along with your-github username. So generate PAT using following steps:
1. Go to github.com → click your profile picture → Settings
2. Left sidebar → scroll to bottom → Developer settings
3. Personal access tokens → Tokens (classic)
4. Click Generate new token (classic)

# Second Step: Create first pipeline job that connects to GitHub
## 1. Before building the pipeline project in jenkins create a simple java app to build(since the size of app doesn't matter for us)
1. In your terminal run: "cd ~/devops-cicd-project"
2. Create a simple maven project structure: "mkdir -p myapp/src/main/java/com/devops"
3. Create a Java file: "nano myapp/src/main/java/com/devops/App.java" (You can create the application you wish)
4. Create the maven build file: "nano myapp/pom.xml" (Build the maven build file as your req. configurations)
5. Create jenkins file: "nano ~/devops-cicd-project/Jenkinsfile" 

## 2. Create Jenkins pipeline job that connects to your GitHub repo!
