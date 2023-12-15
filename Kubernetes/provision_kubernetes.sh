#!/bin/bash -e
echo "--------------------------------------------------------------------------------"
echo "Install containerd"
echo "--------------------------------------------------------------------------------"
sudo apt-get update -y
sudo apt-get install -y nfs-common

echo "--------------------------------------------------------------------------------"
echo "Install containerd"
echo "--------------------------------------------------------------------------------"
sudo apt-get update -y
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reload 
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "--------------------------------------------------------------------------------"
echo "Install Kubernetes"
echo "--------------------------------------------------------------------------------"
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
curl -fsSL http://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

echo "--------------------------------------------------------------------------------"
echo "Mount NFS share"
echo "--------------------------------------------------------------------------------"
mkdir /mnt/nfs_share
sudo mount nfsserver:/mnt/nfs_share /mnt/nfs_share