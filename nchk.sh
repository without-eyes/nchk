#!/bin/bash

# No internet connectivity
url="google.com"
echo -n "Checking internet connectivity: "
if curl -Is "$url" | head -n 1 | grep -q "200\|301"; then
    echo "Online"
else
    echo "Offline"
fi

# DNS resolution
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

# Wrong IP address
echo -n "Checking for assigned IP address and subnet mask: "
ip_and_mask="$(ip a | grep "inet " | awk '{print $2}' | tr "/" " ")"
ip_address="$(echo "$ip_and_mask" | awk '{print $1}')"
subnet_mask="$(echo "$ip_and_mask" | awk '{print $2}')"
if [ -z "$ip_address" ] && [ -z "$subnet_mask" ]; then
  echo "No IP address and subnet mask"
elif [ -z "$ip_address" ]; then
  echo "No IP address"
elif [ -z "$subnet_mask" ]; then
  echo "No subnet mask"
else
  echo "Everything is assigned"
fi

# No default gateway
echo -n "Checking if default gateway is existing: "
if ip r | grep -q "default"; then
  echo "Exists"
else
  echo "Not exists"
fi

# DHCP is not working
echo -n "Checking if DHCP is working: "
if ip a | grep -q "dynamic"; then
  echo "Working"
else
  echo "Not working"
fi

# Firewall blocking traffic
if [[ $EUID -ne 0 ]]; then
    echo "Skipping firewall check: Run as root (sudo) to check iptables"
else
    echo -n "Checking firewall rules: "
    if sudo iptables -L -n --line-numbers | grep -qE "DROP|REJECT"; then
        echo "Firewall might be blocking traffic"
    else
        echo "Firewall is not blocking traffic"
    fi
fi

# Incorrect MAC address configuration
echo -n "Checking if MAC address is valid: "
mac_address=$(ip link show | grep -oP '(?<=link/ether )[^ ]+')
if [[ "$mac_address" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
    echo "Valid"
else
    echo "Invalid"
fi

# Wi-fi is not turned on or ethernet is not connected
echo -n "Checking if Ethernet or Wi-Fi is connected: "
if ip link show | grep -q "state UP"; then
    echo "Connected"
else
    echo "Not connected"
fi