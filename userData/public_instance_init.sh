#! /bin/bash

## installing docker
sudo apt-get update
sudo apt-get install -y \
ca-certificates \
curl \
gnupg \
lsb-release \
vim

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

sudo echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

## installing jenkins container
sudo docker pull jenkins/jenkins:lts
sudo docker run -d -p 8181:8080 --name jenkins-container jenkins/jenkins:lts

# How to find initial value of jenkins admin
## docker exec -it jenkins-container /bin/bash
## cat /var/jenkins_home/secrets/initialAdminPassword

## installing nodejs
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs