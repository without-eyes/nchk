# Network Diagnostic Utility

## Overview
This Bash script performs a series of network diagnostics to identify potential connectivity issues. It checks internet connectivity, DNS resolution, packet loss, latency, IP address assignment, default gateway presence, DHCP status, firewall rules, MAC address validity and network interface connectivity.

## Features
- **Internet Connectivity Check**: Verifies if the system is online using HTTP status codes.
- **DNS Resolution Test**: Ensures domain names resolve correctly.
- **Packet Loss Detection**: Measures network packet loss using ICMP ping.
- **Latency Measurement**: Checks response time to a target IP.
- **IP Address & Subnet Mask Verification**: Ensures a valid IP address is assigned.
- **Default Gateway Check**: Confirms the presence of a default gateway.
- **DHCP Functionality Test**: Detects if the system is obtaining an IP dynamically.
- **Firewall Rule Check**: Identifies if traffic is being blocked.
- **MAC Address Validation**: Ensures the system has a correctly formatted MAC address.
- **Network Interface Status**: Determines if Ethernet or Wi-Fi is connected.

## Usage
Run the script with:
```bash
sudo ./nchk.sh
```
**Note**: Some checks require root privileges (e.g., firewall inspection).

## Requirements
- Bash
- `curl` for connectivity checks
- `dig` for DNS resolution
- `ping` for latency and packet loss tests
- `ip` command for network interface inspection
- `iptables` (optional) for firewall checks
- `grep`, `awk`, `sed` for string formatting

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
