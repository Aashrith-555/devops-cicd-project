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
