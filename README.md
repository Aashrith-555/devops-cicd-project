# devops-cicd-project
Full CI/CD pipeline using Jenkins, Docker, Ansible, K8s on Azure

# Setting up the tools using the script setup.sh from the following commands in a linux environment
git clone https://github.com/"YourGitHubUsername"/devops-cicd-project.git
cd devops-cicd-project
./setup.sh

# Use following commands to push the updated code into git everytime you edit
cd ~/devops-cicd-project
git add setup.sh
git commit -m "Update for the session"
git push origin main

# Note:
Everytime while pushing the file into main branch the OS asks for Personal Access Token (PAT) as password along with your-github username. So generate PAT using following steps:
1. Go to github.com → click your profile picture → Settings
2. Left sidebar → scroll to bottom → Developer settings
3. Personal access tokens → Tokens (classic)
4. Click Generate new token (classic)

