# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# Vagrant file for a postfix email server environment.
#
#
# SETUP:
# ======
#
# Linux:
# ------
# I used Ubuntu 13.10 as my host O.S.; I installed the latest Vagrant, v 1.5.1
# by downloading the .deb file from http://www.vagrantup.com/downloads.html
# and then installing via:
#
#   sudo dpkg -i vagrant_1.5.0_x86_64.deb
#
# I installed virtualbox via `sudo apt-get install virtualbox-4.2`.
# The guest box I selected, a bundle built by Puppet Labs that is
# based on Ubuntu 12.04 Precise i386 with Puppet 3 installed.  This
# box also came bundled with guest addtions for virtualbox 4.2., which is
# perfect.
#
# It is not necessary to install puppet on your host system.
#
# Windows/Mac:
# ------------
# Download the appropriate Vagrant 1.5.1 installer for your platform from:
#
#   http://www.vagrantup.com/downloads.html
#
# Running the installer is straightforward.  You can put off restarting.
# Next, download Virtualbox 4.2 from:
#
#   https://www.virtualbox.org/wiki/Download_Old_Builds_4_2
#
# Again, installation is fairly straightforward.  All available components
# will be pre-selected for installation; this is fine. There are a lot of
# annoying "Would you like to install..." dialongs that you need to click
# through; you can just trust everything from Oracle corporation if you want.
#
# Once you have installed both Vagrant and Virtualbox, it's probably a good
# time to restart your computer.
#
# USAGE:
# ======
#
# $ vagrant up postfix
# $ vagrant ssh postfix
#
# Profit.
#
# Note: the 'client' box is for testing, but this is not used yet.
#
#
Vagrant.configure("2") do |config|
  # email requires a working DNS server with reverse lookup entries;
  # not sure that we will actually test this so robustly that this will
  # be required, but we'll maintain it as-is for a while.  We will
  # therefore, at least for the time being, set up our own DNS server,
  # and add an entry to it in /etc/resolv.conf for every host we create.
  dns_local_ip = "192.168.213.201"

  config.vm.provision "shell", inline: "echo Welcome to Vagrant for postfix"

  # See: http://askubuntu.com/questions/238040/how-do-i-fix-name-service-for-vagrant-client
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.define "postfix", primary: true do |node|
    node.vm.box = "precise-puppet-3"
    node.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"

    # The postfix server has the DNS server
    private_address = dns_local_ip
    node.vm.network "private_network", ip: private_address,
      virtualbox__intnet: "isolatednetwork"
    #node.vm.provision :hosts

    # Provision with puppet.
    node.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "postfix.pp"
      puppet.facter = {
        "vagrant" => "1",
        "hostname" => "postfix",
        "domain" => "postfix.local",
        "ip_address" => private_address,
      }
    end

    node.vm.provision "shell", inline: "resolvconf -d eth0.dhclient && echo nameserver 192.168.213.201 | resolvconf -a eth0.local"
  end

  config.vm.define "client" do |node|
    node.vm.box = "precise-puppet-3"
    node.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box"

    private_address = "192.168.213.202"
    node.vm.network "private_network", ip: private_address,
      virtualbox__intnet: "isolatednetwork"
    #node.vm.provision :hosts

    # Provision with puppet.
    node.vm.provision :puppet do |puppet|
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.manifests_path = "puppet/manifests"
      puppet.module_path = "puppet/modules"
      puppet.manifest_file  = "client.pp"
      puppet.facter = {
        "vagrant" => "1",
        "hostname" => "client",
        "domain" => "postfix.local",
        "ip_address" => private_address,
      }
    end

    node.vm.provision "shell", inline: "resolvconf -d eth0.dhclient && echo nameserver 192.168.213.201 | resolvconf -a eth0.local"

  end

end
