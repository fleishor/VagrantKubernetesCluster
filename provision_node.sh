#!/bin/bash -e

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
echo "Join worker node to kubernetes cluster"
echo "--------------------------------------------------------------------------------"
sudo /vagrant/join_command.sh

echo "--------------------------------------------------------------------------------"
echo "Set worker node name in kubernetes cluster"
echo "--------------------------------------------------------------------------------"
whoami
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker
