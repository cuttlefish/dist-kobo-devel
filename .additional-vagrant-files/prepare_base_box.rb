# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if ENV.keys.include? "VM_BOX"
    config.vm.box = ENV["VM_BOX"]
  else
    config.vm.box = "ubuntu/trusty32"
    config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box"
  end

  # 8000, 8001, 8005
  [0, 1, 5].each do |pn|
    hpn = starting_port_number + pn
    gpn = 8000 + pn
    config.vm.network :forwarded_port, host: hpn, guest: gpn
  end

  if ENV["LIVE_RELOAD"]
    config.vm.network :forwarded_port, host: 35729, guest: 35729
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true


  config.vm.synced_folder "./scripts", "/home/vagrant/scripts", type: "rsync"
  config.vm.synced_folder "./env", "/home/vagrant/env", type: "rsync"


  if File.directory? "src"
    config.vm.synced_folder "./src", "/home/vagrant/src", type: "rsync"
  end

  config.vm.provision :shell, inline: <<SCRIPT
    # Suppress subsequent stdin/tty complaints (for `root` user only).
    sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile

    # ensure a src directory exists and has the correct warnings
    mkdir -p /home/vagrant/src /home/vagrant/logs /home/vagrant/backup

    # make all directories in vagrant owned by vagrant
    sudo chown -R vagrant:vagrant /home/vagrant

    # ensure the environment variables are loaded in .profile and .bashrc
    src_file="/home/vagrant/scripts/01_environment_vars.sh"
    for f in "/home/vagrant/.profile" "/etc/bash.bashrc" "/root/.profile"; do
      if [ "$(sudo grep $src_file $f)" = "" ]; then
        echo "sourcing '$src_file' in '$f'"
        echo "[ -f $src_file ] && { . $src_file; }" | sudo tee -a $f > /dev/null
      fi
    done

    [ -f $HOME_VAGRANT/.mark_keys_added ] || {
        su - root -c "sh $V_S/02_installation_keys.sh"
    }

    su - root -c        "sh   $V_S/03_apt_installs.sh"
    su - root -c        "sh   $V_S/04_postgis_extensions.sh"
    su - vagrant -c     "bash $V_S/kc_10_virtualenvs.bash"
    su - vagrant -c     "sh   $V_S/kc_20_clone_code.sh"
    su - vagrant -c     "bash $V_S/kc_30_install_pip_requirements.bash"
    su - root -c        "bash $V_S/kc_60_environment_setup.bash"

    # KoBoForm:
    su - vagrant -c     "bash $V_S/kf_10_virtualenvs.bash"
    su - vagrant -c     "sh   $V_S/kf_20_clone_code.sh"
    su - vagrant -c     "bash $V_S/kf_30_install_pip_requirements.bash"
    su - vagrant -c     "HOME=$VAGRANT_HOME sh   $V_S/kf_40_npm_installs.sh"

    # skipping all enketo installs
    bash "$V_S/X_teardown.bash"

SCRIPT
end
