#!/bin/bash

export MONIP=${MONIP:="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')"}
firewall-cmd --zone=public --add-rich-rule="rule family="ipv4" source address=""$MONIP"/24" port protocol="tcp" port="6789" accept"
firewall-cmd --zone=public --add-rich-rule="rule family="ipv4" source address=""$MONIP"/24" port protocol="tcp" port="6789" accept" --permanent
echo $MONIP
