# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  #  config.vm.box = "ubuntu/trusty64"
  config.vm.box = "ubuntu/trusty64/chef12-v2"
  config.vm.network "forwarded_port", guest: 80, host: 3000
  config.vm.network :private_network, ip: "10.0.3.2"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end
  config.vm.provision "chef_solo" do |chef|
    chef.json = {
        "developer_mode" => true
    }
    chef.cookbooks_path = "./"
    chef.add_recipe 'nephology::nat'
    chef.add_recipe 'nephology::ipxe'
    chef.add_recipe 'nephology::dhcpd'
    chef.add_recipe 'nephology::server'
  end
end
