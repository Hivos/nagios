#!/bin/bash

echo command[check_disk]=/usr/lib64/nagios/plugins/check_disk -w 20% -c 10% -p /dev/mapper/rootvg01-lv01  >> /etc/nagios/nrpe.cfg
systemctl restart nrpe
