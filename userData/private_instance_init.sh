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

## installing mysql container
sudo docker pull mysql:5
sudo docker run -d -p 8181:8080 -v /jenkins:/var/jenkins_home --name jenkins-container jenkins/jenkins:lts