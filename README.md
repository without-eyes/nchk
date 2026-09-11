# Network Diagnostic Utility (nchk)

## Overview
This Bash script performs a comprehensive series of network diagnostics, moving from local hardware and interface layers up to external internet connectivity. It includes interactive and automated self-healing capabilities to resolve common network configuration problems.

## Features
* **Auto-Fix Capabilities**: Interactively prompts the user to fix detected issues, or applies fixes automatically when the `--auto-fix` flag is passed.
* **Network Interface Status**: Determines if Ethernet or Wi-Fi is connected.
* **MAC Address Validation**: Ensures the system has a correctly formatted MAC address.
* **Firewall Rule Check**: Identifies if traffic is being blocked and supports resetting rules.
* **DHCP Functionality Test**: Detects dynamic IP assignment issues and supports lease renewal.
* **Default Gateway Check**: Confirms the presence of a default gateway and supports network service restarts.
* **IP Address & Subnet Mask Verification**: Ensures a valid IP address and subnet mask are assigned.
* **Packet Loss Detection**: Measures network packet loss using ICMP ping.
* **Latency Measurement**: Checks response time and evaluates network delay.
* **DNS Resolution Test**: Ensures domain names resolve correctly and supports injecting fallback DNS.
* **Internet Connectivity Check**: Verifies if the system is online using HTTP status codes.

## Usage
Run the script with root privileges for full diagnostic and repair capabilities:
```bash
sudo ./nchk.sh
```

To run diagnostics and automatically fix any identified issues without prompting:
```bash
sudo ./nchk.sh --auto-fix
```

**Note**: Some checks and fixes require root privileges (e.g., firewall inspection and system-level networking changes).

## Requirements
* Bash
* `curl` for connectivity checks
* `dig` for DNS resolution
* `ping` for latency and packet loss tests
* `ip` command for network interface inspection
* `iptables`, `systemctl`, `dhclient` (required for specific auto-fix routines)
* `grep`, `awk`, `sed` for string formatting

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
