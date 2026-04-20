# Fresh VM Setup Guide
## Complete Steps to Get Full Pipeline Running from Scratch

---

## ⏱️ Total Time Required: ~30-40 minutes

---

## PHASE 1 — Azure VM Creation (5 minutes)

### Step 1: Create the VM
1. Go to [portal.azure.com](https://portal.azure.com)
2. Search **"Virtual Machines"** → Click **Create**
3. Fill in these settings:

| Field | Value |
|-------|-------|
| Resource group | Your allocated resource group |
| OS Image | **Ubuntu Server 24.04 LTS** |
| Size | **Standard B2ms** (2 vCPUs, 8GB RAM) |
| Authentication | **Password** |
| Username | anything (note it down) |
| Inbound ports | ✅ SSH (22), ✅ HTTP (80) |

4. Click **Review + Create** → **Create**
5. Wait ~2 minutes for deployment to complete

### Step 2: Add Required Ports to NSG
After VM is created:
1. Go to your VM → left sidebar → **Network settings**
2. Click **Add inbound port rule** — add these one by one:

| Port | Name | Why |
|------|------|-----|
| 8080 | Allow-Jenkins-8080 | Jenkins web UI |
| 8085 | Allow-App-8085 | Your web application |

3. Click **Add** after each rule

### Step 3: Get Your Public IP
- On VM overview page, copy the **Public IP address** (looks like `20.x.x.x`)

---

## PHASE 2 — SSH Into VM (2 minutes)

### Step 4: Open Cloud Shell
1. In Azure Portal, click the **`>_`** icon at the top bar
2. Select **Bash**

### Step 5: SSH Into Your VM
```bash
ssh <your-username>@<your-public-ip>
```
Example:
```bash
ssh azureuser@20.185.x.x
```
- Type `yes` when asked about fingerprint
- Enter your VM password

✅ You should see: `azureuser@your-vm-name:~$`

---

## PHASE 3 — Bootstrap the VM (10-15 minutes)

### Step 6: Clone Your Project Repo
```bash
git clone https://github.com/Aashrith-555/devops-cicd-project.git
cd devops-cicd-project
```
- Username: `Aashrith-555`
- Password: Your GitHub PAT (Personal Access Token)

### Step 7: Run the Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

**Wait for "All done!" message at the end.**

This installs: Java 21, Jenkins, Maven, Docker, Git, Azure CLI, Ansible, kubectl, Minikube

### Step 8: Apply Docker Group Permissions
```bash
newgrp docker
```

> ⚠️ This must be run after setup.sh every session — it activates docker group without needing to logout

### Step 9: Install Ansible Docker Collection
```bash
ansible-galaxy collection install community.docker
```

### Step 10: Start Minikube
```bash
minikube start --driver=docker
```
Wait for: `🏄 Done! kubectl is now configured`

This takes ~3-5 minutes.

### Step 11: Verify Everything is Running
```bash
# Check Jenkins
sudo systemctl is-active jenkins

# Check Docker
sudo systemctl is-active docker

# Check Minikube
minikube status

# Check kubectl
kubectl get nodes
```

✅ Expected output:
```
active          ← Jenkins
active          ← Docker
minikube: Running
kubernetes: Running
apiserver: Running
NAME       STATUS
minikube   Ready
```

---

## PHASE 4 — Configure Jenkins (5 minutes)

### Step 12: Open Jenkins in Browser
```
http://<your-public-ip>:8080
```

### Step 13: Unlock Jenkins
Get the admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Copy and paste it into the Jenkins unlock page → **Continue**

### Step 14: Install Plugins
- Click **"Install suggested plugins"**
- Wait ~3-5 minutes for all plugins to install

### Step 15: Create Admin User
Fill in:
- Username: `admin`
- Password: something memorable
- Full name and email

Click **Save and Continue** → **Save and Finish** → **Start using Jenkins**

### Step 16: Create Pipeline Job
1. Click **"New Item"** on left sidebar
2. Name: `devops-pipeline`
3. Select **Pipeline** → Click **OK**
4. Scroll to **Pipeline** section at bottom
5. Change Definition to: **Pipeline script from SCM**
6. Fill in:

| Field | Value |
|-------|-------|
| SCM | Git |
| Repository URL | `https://github.com/Aashrith-555/devops-cicd-project.git` |
| Credentials | None (public repo) |
| Branch Specifier | `*/main` |
| Script Path | `Jenkinsfile` |

7. Click **Save**

---

## PHASE 5 — Fix Jenkins Permissions (3 minutes)

### Step 17: Give Jenkins Docker Access
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Step 18: Give Jenkins Kubernetes Access
```bash
# Copy kubeconfig
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

# Copy Minikube certificates
sudo mkdir -p /var/lib/jenkins/.minikube
sudo cp -r ~/.minikube/ca.crt /var/lib/jenkins/.minikube/
sudo cp -r ~/.minikube/profiles /var/lib/jenkins/.minikube/
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube

# Fix certificate paths in kubeconfig
sudo sed -i "s|$HOME/.minikube|/var/lib/jenkins/.minikube|g" /var/lib/jenkins/.kube/config
```

---

## PHASE 6 — Run the Pipeline (5 minutes)

### Step 19: Trigger First Build
1. Go to Jenkins → **devops-pipeline**
2. Click **"Build Now"** on left sidebar
3. Click on **#1** under Build History
4. Click **"Console Output"** to watch live

### Step 20: Verify All 6 Stages Pass
```
✅ Clone Code
✅ Build with Maven
✅ Docker Build
✅ Push to Docker Hub
✅ Ansible Deploy
✅ Kubernetes Deploy
```

---

## PHASE 7 — Verify Everything Works (2 minutes)

### Step 21: Check Docker Container
```bash
docker ps
```
✅ Should show `myapp-container` with status `Up`

### Step 22: Check Kubernetes Pods
```bash
kubectl get pods
kubectl get services
```
✅ Should show 2 pods `Running` and `myapp-service` with a NodePort

### Step 23: Test the App Locally
```bash
curl http://localhost:8085
```
✅ Should return: `Hello from DevOps Pipeline!`

### Step 24: Test via Kubernetes
```bash
curl $(minikube service myapp-service --url)
```
✅ Should return: `Hello from DevOps Pipeline!`

### Step 25: Test in Browser
Open in browser:
```
http://<your-public-ip>:8085
```
✅ Should show: `Hello from DevOps Pipeline!`

---

## 🚨 Common Issues and Quick Fixes

| Symptom | Quick Fix |
|---------|-----------|
| `docker: permission denied` | `newgrp docker` |
| `ansible-galaxy: command not found` | `sudo apt-get install -y ansible` |
| `minikube: command not found` | Check setup.sh ran completely |
| Jenkins page not opening | `sudo systemctl start jenkins` |
| Jenkins shows old Jenkinsfile | Push latest changes: `git push origin main` |
| Build fails at Ansible stage | `ansible-galaxy collection install community.docker` |
| Build fails at K8s stage | Redo Step 18 (Jenkins kubeconfig) |
| App not in browser | Check port 8085 added to NSG |
| Container restarting | `docker logs myapp-container` to debug |
| Git push rejected | `git pull origin main --no-rebase` first |
| Git author unknown | `git config --global user.name "Aashrith-555"` |

---

## 📋 Quick Reference Checklist

```
AZURE SETUP
□ VM created (Ubuntu 24.04, Standard B2ms)
□ Port 8080 added to NSG
□ Port 8085 added to NSG
□ Public IP noted

VM BOOTSTRAP
□ SSH into VM
□ git clone repo
□ ./setup.sh completed
□ newgrp docker
□ ansible-galaxy collection install community.docker
□ minikube start --driver=docker

JENKINS SETUP
□ Jenkins unlocked at :8080
□ Suggested plugins installed
□ Admin user created
□ Pipeline job created (devops-pipeline)
□ SCM configured to GitHub repo

PERMISSIONS
□ jenkins added to docker group
□ Jenkins restarted
□ kubeconfig copied to jenkins
□ Minikube certs copied to jenkins
□ cert paths fixed in kubeconfig

VERIFICATION
□ Build Now triggered
□ All 6 stages green
□ docker ps shows container
□ kubectl get pods shows 2 running
□ curl localhost:8085 returns greeting
□ Browser shows greeting
```

---

## ⏱️ Time Breakdown Per Phase

| Phase | Task | Time |
|-------|------|------|
| 1 | Azure VM creation | ~5 min |
| 2 | SSH into VM | ~2 min |
| 3 | Bootstrap (setup.sh + minikube) | ~15 min |
| 4 | Jenkins configuration | ~5 min |
| 5 | Fix permissions | ~3 min |
| 6 | Run pipeline | ~5 min |
| 7 | Verify | ~2 min |
| **Total** | | **~37 min** |

---

*With practice, this entire setup can be done in under 25 minutes.*
