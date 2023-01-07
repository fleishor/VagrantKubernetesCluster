#!/bin/bash -e

echo "--------------------------------------------------------------------------------"
echo "Disable IPv6"
echo "--------------------------------------------------------------------------------"
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
cat <<EOF | sudo tee -a /etc/default/grub
GRUB_CMDLINE_LINUX="ipv6.disable=1"
EOF
sudo update-grub


echo "--------------------------------------------------------------------------------"
echo "Prepare /etc/hosts"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/hosts<<EOF
192.168.56.9 nfsserver
192.168.56.10 master
192.168.56.11 node-01
192.168.56.12 node-02
192.168.56.13 node-03
EOF


echo "--------------------------------------------------------------------------------"
echo "Disable SWAP"
echo "--------------------------------------------------------------------------------"
sudo sed -i '/\sswap\s/ s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sudo rm /swap.img || true

echo "--------------------------------------------------------------------------------"
echo "Load Kernel modules"
echo "--------------------------------------------------------------------------------"
sudo modprobe overlay
sudo modprobe br_netfilter
sudo cat <<EOF | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

echo "--------------------------------------------------------------------------------"
echo "Kernel settings"
echo "--------------------------------------------------------------------------------"
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system


echo "--------------------------------------------------------------------------------"
echo "Install containerd"
echo "--------------------------------------------------------------------------------"
sudo apt-get update -y
sudo apt-get install -y containerd apt-transport-https
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
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get -y install open-iscsi nfs-common vim git wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
