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
echo "Install NFS server"
echo "--------------------------------------------------------------------------------"
sudo apt-get update -y
sudo apt-get install -y nfs-kernel-server

echo "--------------------------------------------------------------------------------"
echo "Create NFS share"
echo "--------------------------------------------------------------------------------"
sudo mkdir -p /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share/
sudo chmod 777 /mnt/nfs_share/


echo "--------------------------------------------------------------------------------"
echo "Export NFS share"
echo "--------------------------------------------------------------------------------"
echo "/mnt/nfs_share 192.168.56.9/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
sudo exportfs -a

echo "--------------------------------------------------------------------------------"
echo "Restart NFS server"
echo "--------------------------------------------------------------------------------"
sudo systemctl restart nfs-kernel-server
