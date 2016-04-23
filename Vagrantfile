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
  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.synced_folder "puppet", "/puppet"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    puppet.hiera_config_path    = "puppet/hiera-config.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.manifest_file  = "site.pp"
    puppet.options = "--verbose"
  end


  #host-only networking

  #Default RAM/CPU config
  config.vm.provider "virtualbox" do |v|
   v.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "2", "--ioapic", "on"]
  end

  config.vm.define "zk" do |zk|
    # zk.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "8", "--ioapic", "on", "--name", "zk.csw.vm"]
    zk.vm.network "private_network", ip: "192.168.56.101", :adapter => 2
    zk.vm.host_name = "zk.csw.vm"
    zk.vm.box = "my7"
  end

#   config.vm.define "ctl" do |ctl|
#     # ctl.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "8", "--ioapic", "on", "--name", "ctl.csw.vm"]
#     ctl.vm.network "private_network", ip: "192.168.56.102", :adapter => 2
#     ctl.vm.host_name = "ctl.csw.vm"
#     ctl.vm.box = "my7"
#   end

end
