#!/bin/bash

# No internet connectivity
url="google.com"
echo -n "Checking internet connectivity: "
if curl -Is "$url" | head -n 1 | grep -q "200\|301"; then
    echo "Online"
else
    echo -e "\033[31mOffline\033[0m"
fi

# DNS resolution
echo -n "Checking DNS resolution: "
if dig +short "$url" | grep -qE '^[0-9]'; then
  echo "Success"
else
  echo -e "\033[31mFailure\033[0m"

  resolv_file_path="/etc/resolv.conf"
  echo -n "Problem: "

  if [ ! -f "$resolv_file_path" ]; then
    echo "$resolv_file_path not found."
  elif [ ! -s "$resolv_file_path" ]; then
    echo "$resolv_file_path is empty."
  else
    echo -e "\033[31mDNS server might be unreachable or misconfigured\033[0m"
  fi
fi

# Packet loss
ip_address="8.8.8.8"
ping_result=$(ping -q -c 10 -i 0.2 -w 3 "$ip_address" 2>/dev/null)
if [ -n "$ping_result" ]; then
  echo -n "Checking packet loss: "
  packet_loss=$(echo "$ping_result" | grep -oP '\d+(?=% packet loss)')
  if [ "$packet_loss" -eq 0 ]; then
    echo "No packet loss"
  else
    echo -e "\033[31mPacket loss is $packet_loss\033[0m"
  fi
else
  echo -e "\033[31mCannot ping: Network is unreachable\033[0m"
fi

# Latency
if [ -n "$ping_result" ]; then
  echo -n "Checking latency: "
  avg_latency="$(echo "$ping_result" | sed -n 5p | tr "/" " " | awk '{print $8}' | tr "." " " | awk '{print $1}')"
  if [ "$avg_latency" -le 50 ]; then
    echo "Normal latency ($avg_latency ms)"
  else
    echo -e "\033[31mHigh latency ($avg_latency ms)\033[0m"
  fi
fi

# Wrong IP address
echo -n "Checking for assigned IP address and subnet mask: "
ip_and_mask="$(ip a | grep "inet " | awk '{print $2}' | tr "/" " ")"
ip_address="$(echo "$ip_and_mask" | awk '{print $1}')"
subnet_mask="$(echo "$ip_and_mask" | awk '{print $2}')"
if [ -z "$ip_address" ] && [ -z "$subnet_mask" ]; then
  echo -e "\033[31mNo IP address and subnet mask\033[0m"
elif [ -z "$ip_address" ]; then
  echo -e "\033[31mNo IP address\033[0m"
elif [ -z "$subnet_mask" ]; then
  echo -e "\033[31mNo subnet mask\033[0m"
else
  echo "Everything is assigned"
fi

# No default gateway
echo -n "Checking if default gateway is existing: "
if ip r | grep -q "default"; then
  echo "Exists"
else
  echo -e "\033[31mNot exists\033[0m"
fi

# DHCP is not working
echo -n "Checking if DHCP is working: "
if ip a | grep -q "dynamic"; then
  echo "Working"
else
  echo -e "\033[31mNot working\033[0m"
fi

# Firewall blocking traffic
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[31mSkipping firewall check: Run as root (sudo) to check iptables\033[0m"
else
    echo -n "Checking firewall rules: "
    if sudo iptables -L -n --line-numbers | grep -qE "DROP|REJECT"; then
        echo -e "\033[31mFirewall might be blocking traffic\033[0m"
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
    echo -e "\033[31mInvalid\033[0m"
fi

# Wi-fi is not turned on or ethernet is not connected
echo -n "Checking if Ethernet or Wi-Fi is connected: "
if ip link show | grep -q "state UP"; then
    echo "Connected"
else
    echo -e "\033[31mNot connected\033[0m"
fi