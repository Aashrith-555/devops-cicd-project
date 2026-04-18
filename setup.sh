#!/bin/bash

echo "===== Updating system packages ====="
sudo apt-get update -y

echo "===== Installing Java(For Jenkins) ====="
sudo apt-get install -y fontconfig openjdk-21-jre

echo "===== Setting Java 21 as default ====="
sudo update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java

echo "===== Adding Jenkins GPG key ====="
sudo gpg --batch --yes --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
sudo gpg --batch --yes --export 7198F4B714ABFC68 | sudo tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null

echo "===== Adding Jenkins repository ====="
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "===== Installing Jenkins ====="
sudo apt-get update -y
sudo apt-get install -y jenkins

echo "===== Installing Maven ====="
sudo apt-get install -y maven

echo "===== Installing Docker ====="
sudo apt-get install -y docker.io
sudo systemctl enable docker 
sudo systemctl start docker
sudo usermod -aG docker azureuser
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
newgrp docker

echo "===== Installing Azure CLI ====="
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo "===== Installing Git ====="
sudo apt-get install -y git

echo "===== Starting Jenkins ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Fixing Docker Permission for Jenkins ====="
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

echo "===== Verifying installations ====="
echo "Java version:"; java -version
echo "Jenkins status:"; sudo systemctl is-active jenkins
echo "Docker status:"; sudo systemctl is-active docker
echo "Maven version:"; mvn -version
echo "Git version:"; git --version

echo "===== Configure Git ====="
git config --global user.name "Aashrith-555"
git config --global user.email "aashrithkalikota@gmail.com"

echo "===== All done! ====="
echo "Jenkins is at: http://20.80.84.242:8080"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
