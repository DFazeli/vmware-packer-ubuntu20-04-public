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
# Disable Cloud Init
touch /etc/cloud/cloud-init.disabled
echo '> Packer Template Build -- Complete'
