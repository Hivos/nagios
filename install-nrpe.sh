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

#Add bandwidth check
wget https://raw.githubusercontent.com/Hivos/nagios-plugins/master/check_bandwidth.sh -O /usr/local/sbin/check_bandwidth.sh
chmod +rx /usr/local/sbin/check_bandwidth.sh
sed -i "s^eth0^$(ip a|grep 192. -B2|grep mtu|grep -v DOWN|awk '{print $2}'|sed 's/://g')^" /usr/local/sbin/check_bandwidth.sh
echo command[check_bandwidth]=/usr/local/sbin/check_bandwidth.sh >> /etc/nagios/nrpe.cfg
echo command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/mapper/rootvg01-lv01  >> /etc/nagios/nrpe.cfg

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

