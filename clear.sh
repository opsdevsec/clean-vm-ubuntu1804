#!/bin/bash
sudo apt -y update
sudo apt -y dist-upgrade
sudo apt -y autoremove
sudo apt -y install open-vm-tools qemu-guest-agent cloud-init
sudo systemctl stop rsyslog
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f /etc/ssh/ssh_host_*
cat << 'EOL' | sudo tee /etc/rc.local
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL
chmod +x /etc/rc.local
sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost
apt clean
sed -i 's/optional: true/dhcp-identifier: mac/g' /etc/netplan/50-cloud-init.yaml
sudo cloud-init clean --logs
cat /dev/null > ~/.bash_history && history -c
history -w
poweroff
