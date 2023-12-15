echo "--------------------------------------------------------------------------------"
echo "Generate Vagrant.CA certificate"
echo "--------------------------------------------------------------------------------"
openssl genrsa -out Vagrant.CA.key 4096
openssl req -x509 -new -nodes -key Vagrant.CA.key -sha256 -days 390 -out Vagrant.CA.crt -subj "/C=DE/ST=BY/O=Vagrant/CN=Vagrant.CA"

echo "--------------------------------------------------------------------------------"
echo "Install certificate at desktop"
echo "--------------------------------------------------------------------------------"
sudo cp Vagrant.CA.crt /usr/local/share/ca-certificates/Vagrant.CA.crt
sudo update-ca-certificates
#awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep Vagrant.CA

echo "--------------------------------------------------------------------------------"
echo "Create certificate for rancher.vboxnet0"
echo "--------------------------------------------------------------------------------"
openssl genrsa -out rancher.vboxnet0.key 4096
openssl req -new -key rancher.vboxnet0.key -out rancher.vboxnet0.csr -subj "/C=DE/ST=BY/O=Vagrant/CN=rancher.vboxnet0"
openssl x509 -req -in rancher.vboxnet0.csr -CA Vagrant.CA.crt -CAkey Vagrant.CA.key -CAcreateserial -out rancher.vboxnet0.crt -days 390 -sha256 -extfile rancher.vboxnet0.ext
cat rancher.vboxnet0.crt Vagrant.CA.crt >> ssl-bundle-rancher.crt

