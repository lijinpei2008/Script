#!/bin/bash
echo "=================================================================== Please Run WSL As AdminiStrator ========================================================================"
read whit

echo "=========================================================== To check if virtualization is supported on Linux ==============================================================="
grep -E --color 'vmx|svm' /proc/cpuinfo

echo "================================================================= Install Minikube via direct download ====================================================================="
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 

echo "=========================================================================== Add chmod +x ==================================================================================="
sudo chmod +x ./minikube

echo "===================================================================== Move file to /usr/local/bin =========================================================================="
sudo mkdir -p /usr/local/bin/

sudo install minikube /usr/local/bin/

echo "========================================================================= minikube version ================================================================================="
sudo minikube version

echo "================================================================== Virtualization is supported(y/N)? ======================================================================="
read key
if [ ${key} == "Y" -o ${key} == "y" ]
then
    sudo minikube start
else
    sudo minikube start --vm-driver=none
fi

echo "========================================================================== Install Kubectl ================================================================================="
echo "========================================================================= DownLoad Kubectl ================================================================================="
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

echo "============================================================================ apt update ===================================================================================="
sudo apt update

echo "============================================================================ apt install ==================================================================================="
sudo apt install -y apt-transport-https

echo "=========================================================================== Add chmod +x ==================================================================================="
chmod +x ./kubectl

echo "===================================================================== Move file to /usr/local/bin =========================================================================="
sudo mv ./kubectl /usr/local/bin/kubectl

echo "================================================================ Install using native package management ==================================================================="
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt install -y kubectl

echo "================================================================= kubectl apply -f azure-vote.yaml ========================================================================="
sudo kubectl apply -f azure-vote.yaml

echo "========================================================================== kubectl version ================================================================================="
sudo kubectl version

echo "======================================================================= kubectl cluster-info ==============================================================================="
sudo kubectl cluster-info

echo "===================================================================== kubectl cluster-info dump ============================================================================"
sudo kubectl cluster-info dump

echo "========================================================================= kubectl get nodes ================================================================================"
sudo kubectl get nodes