#!/bin/bash

# DNS resolution
url="google.com"
echo -n "Checking DNS resolution: "

if dig +short "$url" | grep -qE '^[0-9]'; then
  echo "Success"
else
  echo "Failure"

  resolv_file_path="/etc/resolv.conf"
  echo -n "Problem: "

  if [ ! -f "$resolv_file_path" ]; then
    echo "$resolv_file_path not found."
  elif [ ! -s "$resolv_file_path" ]; then
    echo "$resolv_file_path is empty."
  else
    echo "DNS server might be unreachable or misconfigured."
  fi

  exit 1
fi

# Packet loss or high latency
# Wrong IP address, subnet mask, or gateway
# Routing table issues or misconfigured routes
# Firewall blocking traffic
# ISP issues or upstream network failures
# Incorrect MAC address configuration
# Wifi is not turned on or ethernet is not connected
# Other