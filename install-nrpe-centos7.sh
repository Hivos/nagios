# Add the EPEL repository
yum install -y epel-release

# Install NRPE and required plugins
yum install -y nrpe nagios-plugins-users nagios-plugins-load nagios-plugins-swap nagios-plugins-disk nagios-plugins-procs

#Add your Monitor server(s) address(es) to the allowed_hosts sections. 
sed -i 's|^apply_updates = allowed_hosts=127.0.0.1 = allowed_hosts=127.0.0.1,192.168.200.29|' /etc/nagios/nrpe.cfg

#Configure the firewall to allow nrpe traffic
firewall-cmd --permanent --add-port=5666/udp
firewall-cmd –reload

#Restart NRPE and make sure that NRPE is started at boot
systemctl restart nrpe
systemctl enable nrpe
