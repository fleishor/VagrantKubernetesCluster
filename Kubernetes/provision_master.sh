#!/bin/bash -e

master_node=192.168.56.10
pod_network_cidr=10.244.0.0/16
node_name=$(hostname -s)

echo "--------------------------------------------------------------------------------"
echo "Start kubernetes services"
echo "--------------------------------------------------------------------------------"
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "--------------------------------------------------------------------------------"
echo "Download kubernetes images"
echo "--------------------------------------------------------------------------------"
sudo kubeadm config images pull

echo "--------------------------------------------------------------------------------"
echo "Initialize kubernetes"
echo "--------------------------------------------------------------------------------"
sudo kubeadm init --apiserver-advertise-address=$master_node --apiserver-cert-extra-sans=$master_node --pod-network-cidr=$pod_network_cidr --node-name $node_name

echo "--------------------------------------------------------------------------------"
echo "Wait 60s"
echo "--------------------------------------------------------------------------------"
sleep 60

echo "--------------------------------------------------------------------------------"
echo "Copy kubernetes config file to shared folder /vagrant/admin.conf"
echo "--------------------------------------------------------------------------------"
sudo cp -f /etc/kubernetes/admin.conf /vagrant/admin.conf

echo "--------------------------------------------------------------------------------"
echo "Copy kubernetes config file from shared folder to /root/.kube"
echo "--------------------------------------------------------------------------------"
mkdir -p /root/.kube
sudo cp -f /vagrant/admin.conf /root/.kube/config

echo "--------------------------------------------------------------------------------"
echo "Copy kubernetes config file from shared folder to /home/vagrant/.kube"
echo "--------------------------------------------------------------------------------"
mkdir -p /home/vagrant/.kube
sudo cp -f /vagrant/admin.conf /home/vagrant/.kube/config
sudo chown 1000:1000 /home/vagrant/.kube/config

echo "--------------------------------------------------------------------------------"
echo "Generate join command"
echo "--------------------------------------------------------------------------------"
kubeadm token create --print-join-command | tee /vagrant/join_command.sh
chmod +x /vagrant/join_command.sh

echo "--------------------------------------------------------------------------------"
echo "Install flannel network"
echo "--------------------------------------------------------------------------------"
kubectl apply -f /vagrant/flannel.yaml

echo "--------------------------------------------------------------------------------"
echo "Install HELM"
echo "--------------------------------------------------------------------------------"
curl http://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] http://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm