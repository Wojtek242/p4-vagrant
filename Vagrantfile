Vagrant.configure(2) do |config|
  config.vm.box = "generic/ubuntu1804"
  config.vm.provider "libvirt" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.hostname = "qp4"
  config.vm.synced_folder '../virtfs', '/home/vagrant/workspace',
                          create: true, type: "nfs", nfs_udp: false

  config.vm.provision "shell", path: "bootstrap.sh"
end
