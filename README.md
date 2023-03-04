# openvpn-route-only-these-domains

OpenVPN server-side only split-tunnel VPN connections. No client configuration required, all routes pushed down from server. 

Shell script that reads in a list of domains to add to OpenVPN's Configuration > VPN Settings > Routing > Private Subnets

Why? 

You want to split your Internet traffic between your local gateway and use your OpenVPN gateway for specific Internet traffic resolved by domain names.

OpenVPN Setup:

Configuration > VPN Settings > Routing > Yes, Use NAT

Configuration > VPN Settings > Should client Internet traffic be routed through the VPN? > No

Add domains one per line in vpn-route-domains.txt

Add subnets to vpn-route-subnets.txt

CHMOD +x openvpn-private-routing-update.sh

cp openvpn-private-routing-update.sh to /usr/local/openvpn_as/scripts/

Example cron job:
*/90    *       *       *       *       /usr/local/openvpn_as/scripts/openvpn-private-routing-update.sh

