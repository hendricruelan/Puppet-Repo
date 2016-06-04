# -*- mode: ruby -*-
# vi: set ft=ruby :

def validate_plugins()
  required_plugins = [
    'vagrant-cachier',
    'vagrant-hostmanager',
  ]
  missing = []

  required_plugins.each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      missing << "'#{plugin}' plugin required. Install it with \n\n\tvagrant plugin install #{plugin}"
    end
  end

  unless missing.empty?
    missing.each{ |x| STDERR.puts x }
    return false
  end

  return true
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  validate_plugins || exit(1)
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "centos-7-2-x64-virtualbox"
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/wily/current/wily-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.provision :shell, :path => "bootstrap.sh"
  config.vm.synced_folder "puppet", "/puppet"
  config.vm.provision :puppet do |puppet|
    puppet.environment_path = "./puppet/environments"
    puppet.environment = "development"
    puppet.hiera_config_path    = "puppet/hiera-config.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
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
    config.vm.define "ctl#{i}", autostart: false do |ctl|
      ctl.vm.network "private_network", ip: "192.168.56.11#{i}", :adapter => 2
      ctl.vm.host_name = "ctl#{i}.csw.vm"
    end
  end

end
