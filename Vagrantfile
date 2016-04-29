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
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
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
    # puppet.options = [ "--verbose", "--debug" ]
  end


  #host-only networking

  #Default RAM/CPU config
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "2", "--ioapic", "on"]
  end

  (1..3).each do |i|
    config.vm.define "zk#{i}" do |zk|
      # zk.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "8", "--ioapic", "on", "--name", "zk#{i}.csw.vm"]
      zk.vm.network "private_network", ip: "192.168.56.10#{i}", :adapter => 2
      zk.vm.host_name = "zk#{i}.csw.vm"
    end
  end

  (1..3).each do |i|
    config.vm.define "ctl#{i}" do |ctl|
      ctl.vm.network "private_network", ip: "192.168.56.11#{i}", :adapter => 2
      ctl.vm.host_name = "ctl#{i}.csw.vm"
    end
  end

end
