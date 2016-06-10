# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

## User Config
##############################################

class UserConfig
  attr_accessor :machine_config_path
  attr_accessor :install_method
  attr_accessor :vagrant_mount_method
  attr_accessor :java_enabled
  attr_accessor :private_registry

  def self.from_env
    c = self.new
    c.machine_config_path  = ENV.fetch('DCOS_MACHINE_CONFIG_PATH', 'config.yaml')
    c.install_method       = ENV.fetch('DCOS_INSTALL_METHOD', 'ssh_pull')
    c.vagrant_mount_method = ENV.fetch('DCOS_VAGRANT_MOUNT_METHOD', 'virtualbox')
    c.java_enabled         = (ENV.fetch('DCOS_JAVA_ENABLED', 'false') == 'true')
    c.private_registry     = (ENV.fetch('DCOS_PRIVATE_REGISTRY', 'false') == 'true')
    c
  end

  # validate required fields and files
  def validate
    errors = []

    # Validate required fields
    required_fields = [
      :machine_config_path,
      :install_method,
      :vagrant_mount_method,
    ]
    required_fields.each do |field_name|
      field_value = send(field_name.to_sym)
      if field_value.nil? || field_value.empty?
        errors << "Missing required attribute: #{field_name}"
      end
    end

    return errors unless errors.empty?

    # Validate required files
    required_files = [
      :machine_config_path,
    ]
    required_files.each do |field_name|
      file_path = send(field_name.to_sym)
      unless File.file?(file_path)
        errors << "File not found: '#{file_path}'. Ensure that the file exists or reconfigure its location (export #{env_var(field_name)}=<value>)"
      end
    end

    errors
  end

  protected

  # convert field symbol to env var
  def env_var(field)
    "DCOS_#{field.to_s.upcase}"
  end

end

## Plugin Validation
##############################################

def validate_machine_types(machine_types)
  STDERR.puts "machine types:"
  machine_types.each do |name, machine_type|
    STDERR.puts "#{name}\t#{machine_type}"
  end
  master_types = machine_types.select{ |_, cfg| cfg['type'] == 'master' }
  if master_types.empty?
    STDERR.puts 'Must have at least one machine of type master'
    exit 2
  end
end

def raise_errors(errors)
  STDERR.puts "Errors:"
  errors.each do |category, error_list|
    STDERR.puts "  #{category}:"
    error_list.each do |error|
      STDERR.puts "    #{error}"
    end
  end
  exit 2
end

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

  # Assure necessary plugins are present
  validate_plugins || exit(1)

  # optionally configure vagrant-vbguest plugin
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
  end

  # configure vagrant-hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  # hostmanager puts the hostname on 'localhost' for the guest
  # which breaks mesos (for now) so set this to false
  config.hostmanager.manage_guest = false
  config.hostmanager.ignore_private_ip = false

  user_config = UserConfig.from_env

  errors = user_config.validate
  raise_errors(errors) unless errors.empty?

  machine_types =  YAML::load_file(Pathname.new(user_config.machine_config_path).realpath)
  validate_machine_types(machine_types)

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Cache downloads of rpms!
  config.cache.scope = :box

  machine_types.each do |name, machine_type|
    config.vm.define name do |machine|

      machine.vm.hostname = "#{name}.vm"

      # Every Vagrant virtual environment requires a box to build off of.
      config.vm.box = "centos-7-2-x64-virtualbox"
      config.vm.box_url = "https://www.dropbox.com/s/tmhnmklvrpp8ex9/centos-7-2-x64-virtualbox.box?dl=1"

      # Use puppet provisioning:
      config.vm.synced_folder "puppet", "/puppet"
      # custom mount type
      machine.vm.synced_folder '.', '/vagrant', type: user_config.vagrant_mount_method

      # allow explicit nil values in the machine_type to override the defaults
      machine.vm.provider 'virtualbox' do |v, override|
        v.name = machine.vm.hostname
        v.cpus = machine_type['cpus'] || 2
        v.memory = machine_type['memory'] || 2048
        override.vm.network :private_network, ip: machine_type['ip']
      end
    end
  end

  # assure the puppet modules are downloaded
  config.vm.provision :shell, :path => "bootstrap.sh"

  # Use puppet provisioning:
  config.vm.synced_folder "puppet", "/puppet"
  config.vm.provision :puppet do |puppet|
    puppet.environment_path = "./puppet/environments"
    puppet.environment = "development"
    puppet.hiera_config_path    = "puppet/hiera-config.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.options = "--verbose"
    # puppet.options = [ "--verbose", "--debug" ]
  end

  # rerun to make sure rpmnew files are removed
  config.vm.provision :puppet do |puppet|
    puppet.environment_path = "./puppet/environments"
    puppet.environment = "development"
    puppet.hiera_config_path    = "puppet/hiera-config.yaml"
    puppet.working_directory = "/tmp/vagrant-puppet"
    puppet.options = "--verbose"
    # puppet.options = [ "--verbose", "--debug" ]
  end

end
