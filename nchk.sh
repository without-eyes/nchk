#!/bin/bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"


# ===== HELPER FUNCTIONS =====
print_success() {
    echo -e "\033[32m$1\033[0m" # green color
}

print_warning() {
    echo -e "\033[33m$1\033[0m" # yellow color
}

print_error() {
    echo -e "\033[31m$1\033[0m" # red color
}

ask_permission_to_fix() {
    while true; do
        read -p "Do you wish to auto-fix this problem? " yn
        case $yn in
            [Yy] ) fix_problem "$1"; break;;
            [Nn] ) break;;
            * ) echo "Please answer \"y\" or \"n\".";;
        esac
    done
}

fix_problem() {
    target=$1
    case "$target" in
        "firewall")
            echo "Flushing firewall rules..."
            sudo iptables -F
            print_success "Firewall rules reset."
            ;;

        "dgateway")
            echo "Attempting to restart network/dhcp service..."
            sudo systemctl restart NetworkManager 2>/dev/null || sudo systemctl restart networking 2>/dev/null
            print_success "Network service restarted."
            ;;

        "ipmask")
            echo "Re-requesting IP address via DHCP..."
            sudo dhclient -r && sudo dhclient
            print_success "DHCP lease renewed."
            ;;

        "dns")
            echo "Adding fallback Google DNS (8.8.8.8) to resolv.conf..."
            echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
            print_success "Fallback DNS added."
            ;;
    esac    
}


# ===== CHECKS =====

# 1. Wi-Fi / Ethernet status
echo -n "Checking if Ethernet or Wi-Fi is connected: "
if ip link show | grep -q "state UP"; then
    print_success "Connected"
else
    print_error "Not connected"
fi

# 2. MAC address configuration
echo -n "Checking if MAC address is valid: "
mac_address=$(ip link show | grep -oP '(?<=link/ether )[^ ]+')
if echo "$mac_address" | grep -Eq '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$'; then
    print_success "Valid"
else
    print_error "Invalid"
fi

# 3. Firewall blocking traffic
if [ $EUID -ne 0 ]; then
    print_error "Skipping firewall check: Run as root (sudo) to check iptables"
else
    echo -n "Checking firewall rules: "
    if sudo iptables -L -n --line-numbers | grep -qE "DROP|REJECT"; then
        print_error "Firewall might be blocking traffic"
        ask_permission_to_fix "firewall"
    else
        print_success "Firewall is not blocking traffic"
    fi
fi

# 4. DHCP status
echo -n "Checking if DHCP is working: "
if ip a | grep -q "dynamic"; then
  print_success "Working"
else
  print_error "Not working"
fi

# 5. Default gateway
echo -n "Checking if default gateway is existing: "
if ip r | grep -q "default"; then
  print_success "Exists"
else
  print_error "Not exists"
  ask_permission_to_fix "dgateway"
fi

# 6. Assigned IP address and subnet mask
echo -n "Checking for assigned IP address and subnet mask: "
ip_and_mask="$(ip a | grep "inet " | awk '{print $2}' | tr "/" " ")"
ip_address="$(echo "$ip_and_mask" | awk '{print $1}')"
subnet_mask="$(echo "$ip_and_mask" | awk '{print $2}')"
if [ -z "$ip_address" ] && [ -z "$subnet_mask" ]; then
  print_error "No IP address and subnet mask"
  ask_permission_to_fix "ipmask"
elif [ -z "$ip_address" ]; then
  print_error "No IP address"
  ask_permission_to_fix "ipmask"
elif [ -z "$subnet_mask" ]; then
  print_error "No subnet mask"
  ask_permission_to_fix "ipmask"
else
  print_success "Everything is assigned"
fi

# 7. Packet loss
ip_ping_target="8.8.8.8"
ping_result=$(ping -q -c 10 -i 0.2 -w 3 "$ip_ping_target" 2>/dev/null)
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

# 8. Latency
if [ -n "$ping_result" ]; then
  echo -n "Checking latency: "
  avg_latency="$(echo "$ping_result" | sed -n 5p | tr "/" " " | awk '{print $8}' | tr "." " " | awk '{print $1}')"
  if [ "$avg_latency" -le 50 ]; then
    print_success "Normal latency ($avg_latency ms)"
  elif [ "$avg_latency" -le 100 ]; then
    print_warning "Slightly high latency ($avg_latency ms)"
  else
    print_error "High latency ($avg_latency ms)"
  fi
fi

# 9. DNS resolution
url="google.com"
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

  ask_permission_to_fix "dns"
fi

# 10. Internet connectivity
echo -n "Checking internet connectivity: "
if curl -Is "$url" | head -n 1 | grep -q "200\|301"; then
    print_success "Online"
else
    print_error "Offline"
fi