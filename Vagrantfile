# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "gobadiah/macos-sierra"

  config.vm.synced_folder ".", "/vagrant", type: "rsync", group: "staff"

  apple_id=""
  apple_password=""
  if ENV['APPLE_ID']
    apple_id = ENV['APPLE_ID']
  end
  if ENV['APPLE_PASSWORD']
    apple_password = ENV['APPLE_PASSWORD']
  end

  $install_dotfiles = <<SCRIPT
chmod +x /vagrant/mac_setup.sh
export APPLE_ID=#{apple_id}
export APPLE_PASSWORD=#{apple_password}
/vagrant/mac_setup.sh
SCRIPT

    config.vm.provision "shell", inline: $install_dotfiles, privileged: false
end
