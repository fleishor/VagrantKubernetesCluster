echo "--------------------------------------------------------------------------------"
echo "Install metallb"
echo "--------------------------------------------------------------------------------"
# https://github.com/metallb/metallb/issues/1540
# Update failurePolicy=Ignore for rule ValidatingWebhookConfiguration for metallb-webhook-configuration
kubectl apply -f /vagrant/metallb-native.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

echo "--------------------------------------------------------------------------------"
echo "Create configuration for metallb"
echo "--------------------------------------------------------------------------------"
kubectl apply -f /vagrant/metallb-configuration.yaml
