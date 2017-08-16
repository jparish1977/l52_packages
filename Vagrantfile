Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end
  config.vm.network "forwarded_port", guest: 80, host: 801
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "l52-packages"
  config.vm.network :private_network, type: "dhcp"
end
