#!/bin/bash -e

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
