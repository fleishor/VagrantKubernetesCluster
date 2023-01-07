# Set IP Adresses of Master and Worker nodes
NFSSERVER_IP    = "192.168.56.9"
MASTER_IP       = "192.168.56.10"
NODE_01_IP      = "192.168.56.11"
NODE_02_IP      = "192.168.56.12"
NODE_03_IP      = "192.168.56.13"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_check_update = false

  # use proxy at host machine
  if Vagrant.has_plugin?("vagrant-proxyconf")
   config.apt_proxy.http = "http://desktop.fritz.box:3142"
   config.apt_proxy.https = "DIRECT"
  end

  # define cpu/memory of nodes
  nodes = [
    { :name => "nfsserver", :ip => NFSSERVER_IP, :cpus => 2, :memory => 4096, :disksize => "32GB" },
    { :name => "master",    :ip => MASTER_IP,    :cpus => 2, :memory => 4096, :disksize => "32GB" },
    { :name => "node-01",   :ip => NODE_01_IP,   :cpus => 2, :memory => 4096, :disksize => "32GB" },
    { :name => "node-02",   :ip => NODE_02_IP,   :cpus => 2, :memory => 4096, :disksize => "32GB" },
    { :name => "node-03",   :ip => NODE_03_IP,   :cpus => 2, :memory => 4096, :disksize => "32GB" },
  ]

  # create virtual machine
  nodes.each do |opts|
    config.vm.define opts[:name] do |node|
      node.vm.hostname = opts[:name]
      node.vm.network "private_network", ip: opts[:ip]
#      node.vm.disk :disk, size: opts[:disksize], primary: true

      node.vm.provider "virtualbox" do |vb|
        vb.name = opts[:name]
        vb.cpus = opts[:cpus]
        vb.memory = opts[:memory]
      end

      # special provision for nfsserver
      if node.vm.hostname == "nfsserver" then 
        node.vm.provision "shell", path:"./provision_nfsserver.sh"
      end
      
      # special provision for master
      if node.vm.hostname == "master" then 
        node.vm.provision "shell", path:"./provision_kubernetes.sh"
        node.vm.provision "shell", path:"./provision_master.sh"
      end

      # special provision for worker nodes
      if node.vm.hostname =~ /node-[0-9]*/ then
        node.vm.provision "shell", path:"./provision_kubernetes.sh"
        node.vm.provision "shell", path:"./provision_node.sh"
      end
    end
  end
end
