#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# Start Minikube
minikube start

# Clone the charts repository
git clone https://github.com/yourusername/charts.git
cd charts

# Create a namespace for Chatwoot
kubectl create namespace chatwoot

# Deploy Chatwoot using Helm
helm install chatwoot ./charts/chatwoot \
  --namespace chatwoot \
  --set postgresql.auth.postgresPassword=your_secure_password \
  --set redis.auth.password=your_secure_password \
  --set env.SECRET_KEY_BASE=$(openssl rand -hex 64) \
  --set env.FRONTEND_URL=http://4.227.155.80:3000

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=chatwoot -n chatwoot --timeout=300s

echo "Chatwoot deployment completed!"
echo "You can access the application at http://4.227.155.80:3000" 