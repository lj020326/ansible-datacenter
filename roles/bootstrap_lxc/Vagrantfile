Vagrant.configure("2") do |config|
  # If you're running into an NFS mount error (using libvirt), you might need
  # to install your distro's NFS server package, enable UDP for nfsd, and start
  # the server (I'd suggest enabling it as well).
  # Reference: https://github.com/hashicorp/vagrant/issues/9666#issuecomment-401931144
  config.vm.box = "generic/ubuntu1804"

  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = 2048
    libvirt.cpus = 2
  end

  config.vm.synced_folder ".", "/vagrant"

  # Performs most of the "install" tasks in .travis.yml
  config.vm.provision "shell", privileged: false,
    path: "vagrant.sh", args: ["install"]

  # Runs an ansible-playbook syntax check
  config.vm.provision "shell", privileged: false,
    path: "vagrant.sh", args: ["syntax"]

  # Attempts to mimic Ansible execution in the Travis environment
  # caveat: python in the VM is older than the one in Travis, which means SNI
  #   is not supported (and possibly other things might be broken)
  config.vm.provision :ansible_local do |ansible|
    ansible.install = false
    ansible.provisioning_path = "/vagrant/tests/"
    ansible.playbook_command = "VIRTUAL_ENV=/home/vagrant/.virtualenv/ PATH=\"$VIRTUALENV:$PATH\" /home/vagrant/.virtualenv/bin/ansible-playbook"
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "deploy.yml"
    ansible.verbose = true
  end

  # Runs ansible-playbook again for idempotence checking
  config.vm.provision "shell", privileged: false,
    path: "vagrant.sh", args: ["idempotence"]
#ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook -i inventory -v test.yml
end
