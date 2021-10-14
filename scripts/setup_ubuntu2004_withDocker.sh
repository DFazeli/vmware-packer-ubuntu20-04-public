#!/usr/bin/bash

echo '> Cleaning apt-get ...'
apt-get clean
# Cleans the machine-id.
echo '> Cleaning the machine-id ...'
rm /etc/machine-id
touch /etc/machine-id
# Start iscsi and ntp
echo '> Start iscsi and ntp ...'
systemctl restart iscsid
systemctl restart ntp
# Cleanup for linux customization in Terraform
mkdir /etc/dhcp3
# Fix VMware Customization Issues KB56409
sed -i '/^\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service
awk 'NR==11 {$0="#D /tmp 1777 root root -"} 1' /usr/lib/tmpfiles.d/tmp.conf | tee /usr/lib/tmpfiles.d/tmp.conf

# Cloud Init Nuclear Option
rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg
echo "disable_vmware_customization: false" >> /etc/cloud/cloud.cfg
echo "# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ VMware, OVF, None ]" > /etc/cloud/cloud.cfg.d/90_dpkg.cfg

# Set boot options to not override what we are sending in cloud-init
echo `> modifying grub`
sed -i -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
update-grub

# Disable Cloud Init
# touch /etc/cloud/cloud-init.disabled
# Install docker
apt update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update -y
apt-cache policy docker-ce
apt install docker-ce -y
groupadd docker
usermod -aG docker ubuntu

echo '> Packer Template Build -- Complete'
