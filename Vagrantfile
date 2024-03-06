# -*- mode: ruby -*-
# vi: set ft=ruby :

var_box = "generic/rocky8"
#var_box = "generic/rhel8"

Vagrant.configure("2") do |config|
  
  config.ssh.extra_args = ["-o", "PubkeyAcceptedKeyTypes=+ssh-rsa", "-o", "HostKeyAlgorithms=+ssh-rsa"]
  config.vm.define "node0" do |nodes|
      nodes.vm.box = var_box
      #nodes.vm.box = "generic/rhel7"
      
      nodes.vm.hostname= "node0"
      #MacOS workaround for VirtualBox 7
      nodes.vm.network "private_network", ip: "192.168.1.10", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.network "forwarded_port", guest: 22, host: "3200", id:'ssh'
      nodes.vm.provider "virtualbox" do |v|
      v.gui = false
      v.memory = "512"
      v.cpus = "1"
      v.name = "vm_node0"
      #v.customize ["modifyvm", :id, "--groups", "/bdr/node0"]
    end
    
    nodes.vm.synced_folder ".", "/vagrant"
    nodes.vm.synced_folder "./keys", "/vagrant_keys"
    nodes.vm.provision "shell", inline: "cp /vagrant/.vagrant/machines/node0/virtualbox/private_key /vagrant_keys/key"
    nodes.vm.provision "shell", inline: <<-SHELL
      sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
      echo -e "root\nroot" | passwd root
      sudo systemctl restart sshd

      sudo sh /vagrant_keys/config.sh
      sudo sh /vagrant_keys/generate_public_key.sh
      sudo sh /vagrant_keys/copy_keys.sh
      sudo sh /vagrant_keys/hostnames.sh
    SHELL
  end

  # BDR Nodes
  (1..3).each do |i|
    config.ssh.extra_args = ["-o", "PubkeyAcceptedKeyTypes=+ssh-rsa", "-o", "HostKeyAlgorithms=+ssh-rsa"]
    config.vm.define "node#{i}" do |nodes|
      nodes.vm.box = "generic/rocky8"
      nodes.vm.hostname = "node#{i}"
      nodes.vm.network "private_network", ip: "192.168.1.1#{i}", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.network "forwarded_port", guest: 5444, host: "544#{i}"
      nodes.vm.network "forwarded_port", guest: 6432, host: "643#{i}"
      nodes.vm.network "forwarded_port", guest: 8443, host: "54#{i}"
      nodes.vm.network "forwarded_port", guest: 8080, host: "8#{i}"
      nodes.vm.network "forwarded_port", guest: 22, host: "320#{i}", id:'ssh'
      
      nodes.vm.provider "virtualbox" do |v|
      v.memory = "1024"
      v.cpus = "2"
      v.name = "vm_node#{i}"
    end
      
    nodes.vm.synced_folder ".", "/vagrant"
    nodes.vm.synced_folder "./keys", "/vagrant_keys"
    nodes.vm.provision "shell", inline: <<-SHELL
        echo -e "root\nroot" | passwd root

        sudo systemctl restart sshd
        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
        sudo sh /vagrant_keys/hostnames.sh

        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl mask --now firewalld
      SHELL
    end
   end

   (4..4).each do |i|
    config.ssh.extra_args = ["-o", "PubkeyAcceptedKeyTypes=+ssh-rsa", "-o", "HostKeyAlgorithms=+ssh-rsa"]
    config.vm.define "node#{i}" do |nodes|
      nodes.vm.box = "generic/rocky9"
      nodes.vm.hostname = "node#{i}"
      nodes.vm.network "private_network", ip: "192.168.1.1#{i}", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.network "forwarded_port", guest: 5444, host: "544#{i}"
      nodes.vm.network "forwarded_port", guest: 6432, host: "643#{i}"
      nodes.vm.network "forwarded_port", guest: 8443, host: "54#{i}"
      nodes.vm.network "forwarded_port", guest: 8080, host: "8#{i}"
      nodes.vm.network "forwarded_port", guest: 22, host: "320#{i}", id:'ssh'
      
      nodes.vm.provider "virtualbox" do |v|
      v.memory = "1024"
      v.cpus = "2"
      v.name = "vm_node#{i}"
    end
      
    nodes.vm.synced_folder ".", "/vagrant"
    nodes.vm.synced_folder "./keys", "/vagrant_keys"
    nodes.vm.provision "shell", inline: <<-SHELL
        echo -e "root\nroot" | passwd root

        sudo systemctl restart sshd
        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
        sudo sh /vagrant_keys/hostnames.sh

        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl mask --now firewalld
      SHELL
    end
   end

   # Barman
  (6..6).each do |i|
    config.vm.define "node#{i}" do |nodes|
    nodes.vm.box = "generic/rocky8"
    nodes.vm.hostname = "node#{i}"
      nodes.vm.network "private_network", ip: "192.168.1.1#{i}", name: "HostOnly", virtualbox__intnet: true
      nodes.vm.provider "virtualbox" do |v|
        v.memory = "512"
        v.cpus = "1"
        v.name = "vm_node#{i}"
      end
      
      nodes.vm.synced_folder ".", "/vagrant"
      nodes.vm.synced_folder "./keys", "/vagrant_keys"

      nodes.vm.provision "shell", inline: <<-SHELL
        sudo systemctl restart sshd
        echo -e "root\nroot" | passwd root

        sh /vagrant_keys/config.sh

        sudo sh /vagrant_keys/config.sh
        sudo sh /vagrant_keys/copy_keys.sh
        sudo sh /vagrant_keys/hostnames.sh
        
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld
        sudo systemctl mask --now firewalld
      SHELL
    end
   end
end
