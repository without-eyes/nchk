#!/bin/bash

print_success() {
    echo -e "\033[32m$1\033[0m" # green color
}

print_error() {
    echo -e "\033[31m$1\033[0m" # red color
}

# No internet connectivity
url="google.com"
echo -n "Checking internet connectivity: "
if curl -Is "$url" | head -n 1 | grep -q "200\|301"; then
    print_success "Online"
else
    print_error "Offline"
fi

# DNS resolution
echo -n "Checking DNS resolution: "
if dig +short "$url" | grep -qE '^[0-9]'; then
  print_success "Success"
else
  print_error "Failure"

  resolv_file_path="/etc/resolv.conf"
  print_error "Problem: "

  if [ ! -f "$resolv_file_path" ]; then
    print_error "$resolv_file_path not found."
  elif [ ! -s "$resolv_file_path" ]; then
    print_error "$resolv_file_path is empty."
  else
    print_error "DNS server might be unreachable or misconfigured"
  fi
fi

# Packet loss
ip_address="8.8.8.8"
ping_result=$(ping -q -c 10 -i 0.2 -w 3 "$ip_address" 2>/dev/null)
if [ -n "$ping_result" ]; then
  echo -n "Checking packet loss: "
  packet_loss=$(echo "$ping_result" | grep -oP '\d+(?=% packet loss)')
  if [ "$packet_loss" -eq 0 ]; then
    print_success "No packet loss"
  else
    print_error "Packet loss is $packet_loss"
  fi
else
  print_error "Cannot ping: Network is unreachable"
fi

# Latency
if [ -n "$ping_result" ]; then
  echo -n "Checking latency: "
  avg_latency="$(echo "$ping_result" | sed -n 5p | tr "/" " " | awk '{print $8}' | tr "." " " | awk '{print $1}')"
  if [ "$avg_latency" -le 50 ]; then
    print_success "Normal latency ($avg_latency ms)"
  else
    print_error "High latency ($avg_latency ms)"
  fi
fi

# Wrong IP address
echo -n "Checking for assigned IP address and subnet mask: "
ip_and_mask="$(ip a | grep "inet " | awk '{print $2}' | tr "/" " ")"
ip_address="$(echo "$ip_and_mask" | awk '{print $1}')"
subnet_mask="$(echo "$ip_and_mask" | awk '{print $2}')"
if [ -z "$ip_address" ] && [ -z "$subnet_mask" ]; then
  print_error "No IP address and subnet mask"
elif [ -z "$ip_address" ]; then
  print_error "No IP address"
elif [ -z "$subnet_mask" ]; then
  print_error "No subnet mask"
else
  print_success "Everything is assigned"
fi

# No default gateway
echo -n "Checking if default gateway is existing: "
if ip r | grep -q "default"; then
  print_success "Exists"
else
  print_error "Not exists"
fi

# DHCP is not working
echo -n "Checking if DHCP is working: "
if ip a | grep -q "dynamic"; then
  print_success "Working"
else
  print_error "Not working"
fi

# Firewall blocking traffic
if [ $EUID -ne 0 ]; then
    print_error "Skipping firewall check: Run as root (sudo) to check iptables"
else
    echo -n "Checking firewall rules: "
    if sudo iptables -L -n --line-numbers | grep -qE "DROP|REJECT"; then
        print_error "Firewall might be blocking traffic"
    else
        print_success "Firewall is not blocking traffic"
    fi
fi

# Incorrect MAC address configuration
echo -n "Checking if MAC address is valid: "
mac_address=$(ip link show | grep -oP '(?<=link/ether )[^ ]+')
if echo "$mac_address" | grep -Eq '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'; then
    print_success "Valid"
else
    print_error "Invalid"
fi

# Wi-fi is not turned on or ethernet is not connected
echo -n "Checking if Ethernet or Wi-Fi is connected: "
if ip link show | grep -q "state UP"; then
    print_success "Connected"
else
    print_error "Not connected"
fi