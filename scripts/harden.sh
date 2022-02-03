#!/bin/sh

# TODO: remove vagrant user
# TODO: create ejbca user with sudoers privileges

export SALT=$(openssl rand -base64 16)
sudo -E useradd -m -p `printf ${EJBCA_USER_PASSWORD} | openssl passwd -6 -salt $SALT -stdin` -s /bin/bash ejbca
sudo sed -i 's/^%sudo.*/%sudo ALL=(ALL:ALL) ALL/g' /etc/sudoers
echo 'ejbca ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/ejbca
sudo chmod 440 /etc/sudoers.d/ejbca

sudo -E useradd -M -p `printf ${EJBCA_USER_PASSWORD} | openssl passwd -6 -salt $SALT -stdin` -s /bin/bash ejbca-remote
echo 'Defaults:ejbca-remote !requiretty' | sudo tee /etc/sudoers.d/ejbca-remote
echo 'ejbca ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ejbca-remote
sudo chmod 440 /etc/sudoers.d/ejbca-remote

sudo rm /etc/sudoers.d/vagrant
