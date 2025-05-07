# OpenVPN Route Only These Domains

A server-side solution for split-tunnel VPN connections using OpenVPN. This script enables routing specific domains through the VPN without requiring client-side configuration, as all routes are pushed from the server.

## Purpose

This script allows you to split your Internet traffic so that only specified domains are routed through the OpenVPN server, while all other traffic uses your local gateway. It dynamically resolves domain names to IP addresses and updates OpenVPN's private routing configuration accordingly.

## Features

- Dynamically resolves domains to IP addresses
- Supports both domain-based and subnet-based routing
- No client-side configuration needed
- Configurable via simple text files
- Automated updates via cron job
- Server-side NAT for seamless routing

## Prerequisites

- OpenVPN Access Server installed and configured
- Administrative access to the server
- Basic knowledge of shell scripting and cron jobs

## Installation

1. Clone or download this repository to your OpenVPN server:

   ```bash
   git clone https://github.com/your-username/openvpn-route-only-these-domains.git

Copy the script to the OpenVPN scripts directory:
bash

cp openvpn-private-routing-update.sh /usr/local/openvpn_as/scripts/

Make the script executable:
bash

chmod +x /usr/local/openvpn_as/scripts/openvpn-private-routing-update.sh

Configuration
OpenVPN Access Server Settings
Log in to the OpenVPN Admin Web UI.

Navigate to Configuration > VPN Settings > Routing.

Set the following:
Should client Internet traffic be routed through the VPN?: No

Yes, Use NAT: Enabled

Save the settings and update the running server.

Input Files
Domains File (vpn-route-domains.txt):
Located at /usr/local/openvpn_as/scripts/vpn-route-domains.txt

Add one domain per line (e.g., example.com)

Comments (lines starting with #) and empty lines are ignored

Example:

example.com
api.example.org
# test.com (disabled)

Subnets File (vpn-route-subnets.txt):
Located at /usr/local/openvpn_as/scripts/vpn-route-subnets.txt

Add one subnet per line in CIDR notation (e.g., 192.168.1.0/24)

Comments and empty lines are ignored

Example:

192.168.1.0/24
10.0.0.0/16
# 172.16.0.0/12 (disabled)

Automation
To keep routes updated (domains may resolve to different IPs over time), schedule the script using a cron job.
Edit the crontab:
bash

crontab -e

Add the following line to run the script every 90 minutes:
bash

*/90 * * * * /usr/local/openvpn_as/scripts/openvpn-private-routing-update.sh

Save and exit. The cron job will now run automatically.

How It Works
The script reads domains from vpn-route-domains.txt and resolves each to an IP address using ping.

Each resolved IP is added as a /32 private network route in OpenVPN's configuration.

Subnets from vpn-route-subnets.txt are added directly as private network routes.

The script updates the OpenVPN configuration using sacli and restarts the service to apply changes.

Logging
The script logs its actions to /var/log/openvpn-private-routing-update.log for troubleshooting. Ensure the directory is writable by the user running the script.
Troubleshooting
Script fails to resolve domains:
Check DNS resolution on the server (ping example.com).

Verify network connectivity.

Routes not applied:
Check the log file for errors.

Ensure sacli commands are executing correctly.

Cron job not running:
Verify the cron service is active (systemctl status cron).

Check cron logs for errors.

Security Considerations
Ensure input files (vpn-route-domains.txt and vpn-route-subnets.txt) are protected (e.g., chmod 600).

Regularly review the domains and subnets for accuracy.

Monitor logs for unexpected behavior.

Contributing
Contributions are welcome! Please submit a pull request or open an issue on the GitHub repository.
License
This project is licensed under the MIT License. See the LICENSE file for details.

   