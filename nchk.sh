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

# Packet loss
ip_address="8.8.8.8"

echo -n "Checking packet loss: "
ping_result=$(ping -q -c 10 -i 0.2 -w 3 "$ip_address")
packet_loss=$(echo "$ping_result" | grep -oP '\d+(?=% packet loss)')
if [ "$packet_loss" -eq 0 ]; then
  echo "No packet loss"
else
  echo "Packet loss is $packet_loss"
fi

# Latency
echo -n "Checking latency: "
avg_latency="$(echo "$ping_result" | sed -n 5p | tr "/" " " | awk '{print $8}' | tr "." " " | awk '{print $1}')"
if [ "$avg_latency" -le 50 ]; then
  echo "Normal latency ($avg_latency ms)"
else
  echo "High latency ($avg_latency ms)"
fi

# Wrong IP address, subnet mask, or gateway
# Routing table issues or misconfigured routes
# Firewall blocking traffic
# ISP issues or upstream network failures
# Incorrect MAC address configuration
# Wifi is not turned on or ethernet is not connected
# Other