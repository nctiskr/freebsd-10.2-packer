# -*- mode: ruby; -*-

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

$num_instances = 1
$instance_name_prefix = "vagrant-freebsd"
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 1

Vagrant.configure("2") do |config|
  config.vm.guest = :freebsd

  # NFS for folder sharing in FreeBSD
  config.vm.synced_folder ".", "/vagrant", :nfs => true, id: "vagrant-root"

  # Global VM config
  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = "builds/freebsd-10.2-virtualbox.box"
    override.vm.box = "freebsd-10.2-virtualbox"

    vb.gui = $vm_gui
    vb.memory = $vm_memory
    vb.cpus = $vm_cpus

    # Disable audio
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]

    # Network adapters are virtual: https://www.virtualbox.org/manual/ch06.html
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  # Instance specific VM config
  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name

      # Static IPs counting up from 10.0.1.10
      ip = "10.0.1.#{i+10}"
      config.vm.network :private_network, ip: ip
    end
  end

end
