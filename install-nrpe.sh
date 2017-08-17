#!/bin/bash
#Define conditional expression
YUM_CMD=$(which yum)

#Check package manager, add the EPEL repository and install NRPE and required plugins
if [[ ! -z $YUM_CMD ]]; then
   yum install -y epel-release
   yum install -y nrpe nagios-plugins-users nagios-plugins-load nagios-plugins-swap nagios-plugins-disk nagios-plugins-procs
else
   apt-get install -y nagios-nrpe-server nagios-plugins
fi

#Add the nagios server(s) address(es) to the allowed_hosts sections. 
sed -i 's|^allowed_hosts=127.0.0.1|allowed_hosts=127.0.0.1,192.168.200.29|' /etc/nagios/nrpe.cfg

#Configure the firewall to allow nrpe traffic, restart NRPE and make sure that NRPE is started at boot
if [[ ! -z $YUM_CMD ]]; then
    firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.200.29/22" port protocol="udp" port="5666" accept'
    firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.200.29/22" port protocol="tcp" port="5666" accept'
    firewall-cmd --reload
    firewall-cmd --reload
    
    systemctl restart nrpe
    systemctl enable nrpe
else
    service nagios-nrpe-server restart
fi

