# DevOps CI/CD Project - Session Notes

## Session 1 - Completed ✅
- Created Azure VM (Ubuntu 24.04, Standard B2ms)
- Opened port 8080 in NSG
- Installed Java 21, Jenkins, Maven, Docker, Git
- Jenkins accessible at http://<your-ip>:8080

## Session 2 - Completed ✅
- Created sample Java app in myapp/
- Created Jenkinsfile with Clone + Build stages
- Created Jenkins pipeline job (devops-pipeline)
- First build successful - Maven BUILD SUCCESS

## Next Session Goals
- Add Docker stage to Jenkinsfile
- Create Dockerfile for the app
- Build and push Docker image to Azure Container Registry (ACR)

## Jenkins Setup Steps (do manually each session for now)
1. Open http://<your-ip>:8080
2. Login with admin credentials
3. New Item → devops-pipeline → Pipeline
4. Pipeline script from SCM → Git
5. Repo: https://github.com/Aashrith-555/devops-cicd-project.git
6. Branch: */main → Save → Build Now

## Session 3 - Completed ✅
- Created Dockerfile with multi-stage build
- Fixed pom.xml to include main class manifest
- Built Docker image successfully locally
- Set up Azure Container Registry (ACR)
- Enabled ACR admin credentials for authentication
- Added Docker Build + ACR Push stages to Jenkinsfile
- Fixed Jenkins Docker permission (added jenkins to docker group)
- Full pipeline working: Clone → Maven Build → Docker Build → ACR Push

## Next Session Goals
- Set up Ansible to automate deployment
- Write Ansible playbook to pull image from ACR and run container
- Add Ansible deployment stage to Jenkinsfile

## Session 4 - Completed ✅
- Switched from ACR to Docker Hub (ACR deleted on session reset)
- Fixed Docker Hub credentials (lowercase username + access token)
- Full pipeline working: Clone → Maven Build → Docker Build → Docker Hub Push

## Next Session Goals
- Install and configure Ansible
- Write Ansible playbook to pull image from Docker Hub and run container
- Add Ansible deployment stage to Jenkinsfile


