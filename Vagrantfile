# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.name = "default"
    virtualbox.customize ["modifyvm", :id, "--memory", "512"]
  end  

  ## Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true
  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.add_recipe "rackspacecloud"
    chef.json = {
       "rackspacecloud" => {
         "fog_version" => "1.21.0"
       }
    }
  end
end

