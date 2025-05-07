#!/bin/bash

# Script to update OpenVPN private routing based on domains and subnets
# Example crontab: */90 * * * * /usr/local/openvpn_as/scripts/openvpn-private-routing-update.sh

# Configuration
DOMAIN_FILE="/usr/local/openvpn_as/scripts/vpn-route-domains.txt"
SUBNET_FILE="/usr/local/openvpn_as/scripts/vpn-route-subnets.txt"
SACLI="/usr/local/openvpn_as/scripts/sacli"
LOG_FILE="/var/log/openvpn-private-routing-update.log"

# Initialize counter
num=0

# Function to log messages
log_message() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check if required files exist
if [[ ! -r "$DOMAIN_FILE" || ! -r "$SUBNET_FILE" ]]; then
    log_message "ERROR: Input file(s) not found or not readable"
    exit 1
fi

# Process domains
while IFS= read -r domain; do
    # Skip empty lines or comments
    [[ -z "$domain" || "$domain" =~ ^# ]] && continue

    # Resolve domain to IP
    ip=$(ping -c1 -W2 "$domain" 2>/dev/null | head -n1 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' || true)
    
    if validate_ip "$ip"; then
        log_message "Processing: $num $domain -> $ip"
        if "$SACLI" --key "vpn.server.routing.private_network.${num}" --value "${ip}/32" ConfigPut; then
            log_message "Successfully updated routing for $domain ($ip)"
        else
            log_message "ERROR: Failed to update routing for $domain ($ip)"
        fi
    else
        log_message "WARNING: Could not resolve or invalid IP for $domain"
    fi
    
    ((num++))
done < "$DOMAIN_FILE"

# Process subnets
while IFS= read -r subnet; do
    # Skip empty lines or comments
    [[ -z "$subnet" || "$subnet" =~ ^# ]] && continue

    log_message "Processing: $num $subnet"
    if "$SACLI" --key "vpn.server.routing.private_network.${num}" --value "$subnet" ConfigPut; then
        log_message "Successfully updated routing for subnet $subnet"
    else
        log_message "ERROR: Failed to update routing for subnet $subnet"
    fi
    
    ((num++))
done < "$SUBNET_FILE"

# Restart service and query config
log_message "Restarting OpenVPN service"
if "$SACLI" start && "$SACLI" ConfigQuery; then
    log_message "Service restarted and configuration queried successfully"
else
    log_message "ERROR: Failed to restart service or query configuration"
    exit 1
fi

exit 0