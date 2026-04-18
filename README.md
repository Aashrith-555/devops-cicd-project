# DevOps CI/CD Pipeline Project

A full CI/CD pipeline built from scratch using Jenkins, Maven, Docker, Ansible, and Kubernetes on Azure.

---

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Tools Used](#tools-used)
- [Project Structure](#project-structure)
- [Step 1 — Environment Setup](#step-1--environment-setup)
- [Step 2 — Java App and First Pipeline](#step-2--java-app-and-first-pipeline)
- [Step 3 — Docker and Image Registry](#step-3--docker-and-image-registry)
- [Step 4 — Ansible Deployment](#step-4--ansible-deployment)
- [Step 5 — Kubernetes Deployment](#step-5--kubernetes-deployment)
- [Full Pipeline Flow](#full-pipeline-flow)
- [Session Management](#session-management)

---

## Project Overview

This project builds a complete DevOps CI/CD pipeline where every code push goes through automated build, containerization, and deployment stages — all defined as code and stored in GitHub.

**Pipeline stages:**
```
Code pushed to GitHub
→ Jenkins pulls and builds with Maven
→ Docker packages the app as a container image
→ Image pushed to Docker Hub
→ Ansible deploys the container on port 8085
→ Kubernetes manages 2 replicas with self-healing
→ App live and accessible in browser
```

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Azure VM (Ubuntu 24.04) | Cloud server to run everything |
| Git + GitHub | Source control and code storage |
| Jenkins | CI/CD automation server |
| Maven | Java build and packaging tool |
| Docker | Containerization |
| Docker Hub | Container image registry |
| Ansible | Automated deployment |
| Kubernetes (Minikube) | Container orchestration |
| Azure CLI | Azure resource management |

---

## Project Structure

```
devops-cicd-project/
├── setup.sh               ← Bootstraps entire VM environment
├── Jenkinsfile            ← 6-stage pipeline definition
├── Dockerfile             ← Multi-stage container build
├── .gitignore             ← Excludes binaries and build output
├── session-notes.md       ← Progress tracker across sessions
├── myapp/                 ← Java web application
│   ├── pom.xml            ← Maven build configuration
│   └── src/main/java/com/devops/
│       └── App.java       ← HTTP server on port 8080
├── ansible/               ← Deployment automation
│   ├── inventory.ini      ← Target server definition
│   └── deploy.yml         ← Deployment playbook
└── k8s/                   ← Kubernetes manifests
    ├── deployment.yaml    ← 2-replica deployment
    └── service.yaml       ← NodePort service
```

---

## Step 1 — Environment Setup

### Prerequisites
- Azure account with VM creation access
- GitHub account with a Personal Access Token (PAT)

### Create Azure VM
1. Go to [portal.azure.com](https://portal.azure.com) → **Virtual Machines** → **Create**
2. Use these settings:

| Field | Value |
|-------|-------|
| OS | Ubuntu Server 24.04 LTS |
| Size | Standard B2ms (2 vCPUs, 8GB RAM) |
| Authentication | Password |
| Inbound ports | SSH (22), HTTP (80) |

3. After VM is created, go to **Network settings** → **Add inbound port rules** for:
   - Port `8080` — Jenkins
   - Port `8085` — Application

### Bootstrap the VM
SSH into your VM and run:
```bash
git clone https://github.com/Aashrith-555/devops-cicd-project.git
cd devops-cicd-project
chmod +x setup.sh
./setup.sh
newgrp docker
ansible-galaxy collection install community.docker
```

The `setup.sh` script installs: Java 21, Jenkins, Maven, Docker, Git, Azure CLI, Ansible, kubectl, and Minikube.

### Generate a GitHub Personal Access Token (PAT)
GitHub requires a PAT instead of your password for `git push`:
1. GitHub → Profile picture → **Settings**
2. Left sidebar → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
3. Click **Generate new token (classic)**
4. Select scope: ✅ `repo`
5. Click **Generate token** → Copy and save it immediately

Use this token as your password whenever Git asks for credentials.

---

## Step 2 — Java App and First Pipeline

### App Structure
The app is a simple Java HTTP server that listens on port 8080 and responds with `Hello from DevOps Pipeline!`

```
myapp/
├── pom.xml
└── src/main/java/com/devops/App.java
```

The `pom.xml` includes the `maven-jar-plugin` configured to set `com.devops.App` as the main class — required for the JAR to be executable.

### Create Jenkins Pipeline Job
1. Open Jenkins at `http://<your-vm-ip>:8080`
2. **New Item** → name: `devops-pipeline` → select **Pipeline** → OK
3. Scroll to **Pipeline** section → change Definition to **Pipeline script from SCM**
4. Fill in:

| Field | Value |
|-------|-------|
| SCM | Git |
| Repository URL | `https://github.com/Aashrith-555/devops-cicd-project.git` |
| Branch | `*/main` |
| Script Path | `Jenkinsfile` |

5. **Save** → **Build Now**

> **Key concept — Pipeline as Code:** The `Jenkinsfile` defines the entire pipeline and lives in GitHub. Jenkins reads it every build — so the pipeline is never lost when the VM resets.

---

## Step 3 — Docker and Image Registry

### Dockerfile
Uses a **multi-stage build**:
- **Stage 1 (build):** Full Maven+Java image compiles and packages the code
- **Stage 2 (run):** Lightweight Alpine image copies only the final JAR

This keeps the final image small (~100MB vs ~500MB).

### Docker Hub Setup
We use Docker Hub instead of Azure Container Registry (ACR) because ACR gets deleted when the Azure session resets, while Docker Hub persists permanently.

1. Create account at [hub.docker.com](https://hub.docker.com)
2. Create a public repository named `myapp`
3. Update credentials in `Jenkinsfile`:
```groovy
DOCKERHUB_USERNAME = 'your-username'
DOCKERHUB_PASSWORD = 'your-password-or-token'
```

### Fix Jenkins Docker Permissions
Jenkins runs as its own user and needs Docker group access:
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

> This is already handled in `setup.sh` for future sessions.

---

## Step 4 — Ansible Deployment

### How It Works
Ansible connects to localhost and:
1. Pulls the latest image from Docker Hub
2. Stops and removes any existing container
3. Runs a new container with port mapping `8085:8080`

### Files

**`ansible/inventory.ini`**
```ini
[local]
localhost ansible_connection=local ansible_user=jenkins
```

**`ansible/deploy.yml`** — pulls image, stops old container, starts new one with `restart_policy: unless-stopped`

### Run Manually
```bash
cd ~/devops-cicd-project/ansible
ansible-playbook -i inventory.ini deploy.yml
```

### Verify
```bash
docker ps
curl http://localhost:8085
```

---

## Step 5 — Kubernetes Deployment

### Setup Minikube
```bash
minikube start --driver=docker
```

### K8s Manifests

**`k8s/deployment.yaml`** — runs 2 replicas of the app with `imagePullPolicy: Always`

**`k8s/service.yaml`** — NodePort service exposing the app

### Deploy Manually
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get services
```

### Access the App
```bash
curl $(minikube service myapp-service --url)
```

### Fix Jenkins Kubectl Access
Jenkins needs access to the Minikube kubeconfig:
```bash
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
sudo mkdir -p /var/lib/jenkins/.minikube
sudo cp -r ~/.minikube/ca.crt /var/lib/jenkins/.minikube/
sudo cp -r ~/.minikube/profiles /var/lib/jenkins/.minikube/
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
sudo sed -i "s|$HOME/.minikube|/var/lib/jenkins/.minikube|g" /var/lib/jenkins/.kube/config
```

> **Key concept — Self healing:** Try deleting a pod with `kubectl delete pod <pod-name>` — Kubernetes immediately creates a replacement. This is the core value of K8s over plain Docker.

---

## Full Pipeline Flow

```groovy
pipeline {
    stages {
        stage('Clone Code')         // Pull latest code from GitHub
        stage('Build with Maven')   // Compile and package JAR
        stage('Docker Build')       // Build container image
        stage('Push to Docker Hub') // Push image to registry
        stage('Ansible Deploy')     // Deploy container on port 8085
        stage('Kubernetes Deploy')  // Deploy 2 replicas to K8s cluster
    }
}
```

---

## Session Management

Since Azure resets all resources every 2.5 hours, this project is designed to be fully reproducible. Every session:

1. Create fresh VM → add ports 8080 and 8085 in NSG
2. SSH in and run:
```bash
git clone https://github.com/Aashrith-555/devops-cicd-project.git
cd devops-cicd-project
chmod +x setup.sh
./setup.sh
newgrp docker
ansible-galaxy collection install community.docker
minikube start --driver=docker
```
3. Copy kubeconfig to Jenkins (see Step 5)
4. Open Jenkins → recreate pipeline job → Build Now
5. Full pipeline runs in ~5 minutes

> **The key principle:** Azure is just the runtime. GitHub is the real project. Everything is code — the VM is disposable.

---

## Common Issues and Fixes

| Issue | Fix |
|-------|-----|
| Jenkins won't start | Check Java version: `java -version` — must be 21+ |
| Docker permission denied | `sudo usermod -aG docker $USER && newgrp docker` |
| Git push rejected | Run `git pull origin main --no-rebase` first |
| Ansible sudo error | Set `become: no` in `deploy.yml` |
| kubectl auth error | Copy kubeconfig to jenkins user (see Step 5) |
| Large files rejected by GitHub | Use `.gitignore` and `git filter-branch` to remove binaries |
