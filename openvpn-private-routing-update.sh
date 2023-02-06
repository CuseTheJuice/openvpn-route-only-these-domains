#!/bin/sh

NUM=0

while read DOMAIN; do
	
	IPADDRESS=`ping -c1 $DOMAIN | head -n1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'`
	echo "$NUM $DOMAIN $IPADDRESS"
	/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.${NUM}" --value "${IPADDRESS}/32" ConfigPut
	NUM=`expr $NUM + 1`

done < /usr/local/openvpn_as/scripts/vpn-route-domains.txt

/usr/local/openvpn_as/scripts/sacli start
/usr/local/openvpn_as/scripts/sacli ConfigQuery
