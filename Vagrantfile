# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  fub_client_path = '../fub_client'
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.provision :shell, path: "install-rvm.sh", args: "stable", privileged: false
  config.vm.provision :shell, path: "install-ruby.sh", args: "2.3.1", privileged: false

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024 # Use 8192 for heavy testing
    v.cpus = 2
  end

  config.vm.network :forwarded_port, guest: 5001, host: 5001

  if File.exist?(fub_client_path)
    config.vm.synced_folder fub_client_path, '/fub_client'
  end
end
