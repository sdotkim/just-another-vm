# -*- mode: ruby -*-
# vi: set ft=ruby :

# The config merge mechanism borrowed from DrupalVM See:
# https://github.com/geerlingguy/drupal-vm
require 'yaml'
# Recursively walk an tree and run provided block on each value found.
def walk(obj, &function)
  if obj.is_a?(Array)
    obj.map { |value| walk(value, &function) }
  elsif obj.is_a?(Hash)
    obj.each_pair { |key, value| obj[key] = walk(value, &function) }
  else
    obj = yield(obj)
  end
end

# Resolve jinja variables in hash.
def resolve_jinja_variables(vconfig)
  walk(vconfig) do |value|
    while value.is_a?(String) && value.match(/{{ .* }}/)
      value = value.gsub(/{{ (.*?) }}/) { vconfig[Regexp.last_match(1)] }
    end
    value
  end
end

# Return the combined configuration content all files provided.
def load_config(files)
  vconfig = {}
  files.each do |config_file|
    if File.exist?(config_file)
      optional_config = YAML.load_file(config_file)
      vconfig.merge!(optional_config) if optional_config
    end
  end
  resolve_jinja_variables(vconfig)
end



host_project_dir = File.dirname(File.expand_path(__FILE__))
vconfig = load_config(
  [
    "#{host_project_dir}/box/config.yml",
    "#{host_project_dir}/box/local.config.yml"
  ]
)


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Set the name of the VM. See: http://stackoverflow.com/a/17864388/100134
  config.vm.define vconfig['vagrant_machine_name']

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = vconfig['vagrant_box']

  # Networking configuration.
  config.vm.hostname = vconfig['vagrant_hostname']

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network,
                    ip: vconfig['vagrant_ip'],
                    auto_network: vconfig['vagrant_ip'] == '0.0.0.0' && Vagrant.has_plugin?('vagrant-auto_network')

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network",  bridge: "wlp5s0"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "~/airlock", "/mnt/airlock", SharedFoldersEnableSymlinksCreate: false
  # Sync the project root directory to /vagrant
  unless vconfig['vagrant_synced_folders'].any? { |synced_folder| synced_folder['destination'] == '/vagrant' }
    vconfig['vagrant_synced_folders'].push(
      'local_path' => host_project_dir,
      'destination' => '/vagrant'
    )
  end

  # Synced folders.
  vconfig['vagrant_synced_folders'].each do |synced_folder|
    options = {
      type: synced_folder.fetch('type', vconfig['vagrant_synced_folder_default_type']),
      rsync__exclude: synced_folder['excluded_paths'],
      rsync__args: ['--verbose', '--archive', '--delete', '-z', '--copy-links', '--chmod=ugo=rwX'],
      id: synced_folder['id'],
      create: synced_folder.fetch('create', false),
      mount_options: synced_folder.fetch('mount_options', []),
      nfs_udp: synced_folder.fetch('nfs_udp', false)
    }
    synced_folder.fetch('options_override', {}).each do |key, value|
      options[key.to_sym] = value
    end
    config.vm.synced_folder synced_folder.fetch('local_path'), synced_folder.fetch('destination'), options
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |v|
    v.linked_clone = vconfig['vagrant_vbox_linked_clone']
    v.memory = vconfig['vagrant_memory']
    v.cpus = vconfig['vagrant_cpus']
    v.customize ['modifyvm', :id, '--ioapic', 'on']
    v.gui = vconfig['vagrant_gui']

    v.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    v.customize ["modifyvm", :id, "--vram", "256"]
    v.customize ["modifyvm", :id, "--accelerate3d", "on"]
    v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
    v.customize ["modifyvm", :id, "--audio", "pulse"]
    v.customize ["modifyvm", :id, "--audiocontroller", "ac97"]
    v.customize ["modifyvm", :id, "--audiocodec", "ad1980"]
    v.customize ["modifyvm", :id, "--audioin", "on"]
    v.customize ["modifyvm", :id, "--audioout", "on"]
    v.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
  end
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = true
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "ansible_local" do |ansible|
    ansible.become = true
    ansible.playbook = "provisioning/playbook.yml"
  end
end
