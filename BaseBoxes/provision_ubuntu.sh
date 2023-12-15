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
192.168.56.1    desktop.fritz.box    desktop
192.168.56.8    admin.vboxnet0       admin
192.168.56.9    nfsserver.vboxnet0   nfsserver
192.168.56.10   master.vboxnet0      master
192.168.56.11   node-01.vboxnet0     node-01
192.168.56.12   node-02.vboxnet0     node-02
192.168.56.13   node-03.vboxnet0     node-03
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
echo "Switch apt from https to http in order to squid-deb"
echo "--------------------------------------------------------------------------------"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo sed -i 's/https:\/\//http:\/\//g' /etc/apt/sources.list

echo "--------------------------------------------------------------------------------"
echo "Update Ubuntu (1. Round)"
echo "--------------------------------------------------------------------------------"
sudo apt-get -y update
sudo apt-get -y upgrade

echo "--------------------------------------------------------------------------------"
echo "Update SSH login"
echo "--------------------------------------------------------------------------------"
wget -O /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
