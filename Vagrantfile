# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "my7"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/wily/current/wily-server-cloudimg-amd64-vagrant-disk1.box"
  # config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.synced_folder "puppet", "/puppet"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    puppet.manifest_file  = "site.pp"
    puppet.options = "--verbose"
  end


  #host-only networking

  #Default RAM/CPU config
  config.vm.provider "virtualbox" do |v|
   v.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "2", "--ioapic", "on"]
  end

  config.vm.define "web" do |web|
    # web.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "8", "--ioapic", "on", "--name", "web.puppetlabs.vm"]
    web.vm.network "private_network", ip: "192.168.56.101", :adapter => 2
    web.vm.host_name = "web.puppetlabs.vm"
    web.vm.box = "my7"
  end

  config.vm.define "db" do |db|
    # db.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "8", "--ioapic", "on", "--name", "db.puppetlabs.vm"]
    db.vm.network "private_network", ip: "192.168.56.102", :adapter => 2
    db.vm.host_name = "db.puppetlabs.vm"
    db.vm.box = "my7"
  end

end
