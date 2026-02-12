import requests
import time
import threading
import os
import sys
from multiprocessing import Value

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

os.system('title Tera Project - Discord Webhook Tool')

# ANSI color codes
class Colors:
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    PURPLE = '\033[95m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_logo():
    logo = r"""
╭━━━━╮
┃╭╮╭╮┃
╰╯┃┃┣┻━┳━┳━━╮
╱╱┃┃┃┃━┫╭┫╭╮┃
╱╱┃┃┃┃━┫┃┃╭╮┃
╱╱╰╯╰━━┻╯╰╯╰╯ V3.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
    print(f"{Colors.PURPLE}{logo}{Colors.END}")

def print_banner():
    banner = r"""
╔══════════════════════════════════════╗
║         Tera project                 ║
║           Version 3.0               ║
╠══════════════════════════════════════╣
║        have a great day! V1         ║
╚══════════════════════════════════════╝
"""
    print(f"{Colors.CYAN}{banner}{Colors.END}")

def send_message(webhook_url, message, i, total, successful, failed, rate_limited):
    retry_count = 0
    max_retries = 3
    
    while retry_count < max_retries:
        try:
            response = requests.post(webhook_url, json={"content": message})
            if response.status_code == 204:
                with successful.get_lock():
                    successful.value += 1
                print(f"{Colors.GREEN}[✓] Webhook #{i+1}/{total} FIRED ✓{Colors.END}")
                return True
            elif response.status_code == 429:
                with rate_limited.get_lock():
                    rate_limited.value += 1
                retry_after = int(response.headers.get("Retry-After", 1))
                print(f"{Colors.YELLOW}[⏱] Rate limit on #{i+1}, waiting {retry_after}s...{Colors.END}")
                time.sleep(retry_after)
                retry_count += 1
            else:
                with failed.get_lock():
                    failed.value += 1
                print(f"{Colors.RED}[✗] Webhook #{i+1}/{total} FAILED ({response.status_code}){Colors.END}")
                return False
        except Exception as e:
            with failed.get_lock():
                failed.value += 1
            print(f"{Colors.RED}[✗] Webhook #{i+1}/{total} ERROR: {str(e)[:30]}{Colors.END}")
            return False
    
    with failed.get_lock():
        failed.value += 1
    print(f"{Colors.RED}[✗] Webhook #{i+1}/{total} MAX RETRIES EXCEEDED{Colors.END}")
    return False

def send_webhook_message(webhook_url, message, count, delay):
    clear_screen()
    print_logo()
    print_banner()
    
    successful = Value('i', 0)
    failed = Value('i', 0)
    rate_limited = Value('i', 0)
    
    print(f"{Colors.YELLOW}{'='*55}{Colors.END}")
    print(f"{Colors.BOLD}    ⚡ LAUNCHING WEBHOOK STORM WITH {count} PAYLOADS ⚡{Colors.END}")
    print(f"{Colors.YELLOW}{'='*55}{Colors.END}\n")
    
    threads = []
    for i in range(count):
        thread = threading.Thread(target=send_message, args=(webhook_url, message, i, count, successful, failed, rate_limited))
        threads.append(thread)
        thread.start()
        if delay > 0:
            time.sleep(delay / 1000)
    
    for thread in threads:
        thread.join()
    
    print(f"\n{Colors.CYAN}{'═'*55}{Colors.END}")
    print(f"{Colors.BOLD}                    MISSION COMPLETE{Colors.END}")
    print(f"{Colors.CYAN}{'═'*55}{Colors.END}")
    print(f"{Colors.GREEN}  ✓ Successful: {successful.value}/{count}{Colors.END}")
    print(f"{Colors.RED}  ✗ Failed: {failed.value}/{count}{Colors.END}")
    print(f"{Colors.YELLOW}  ⏱ Rate Limited: {rate_limited.value}{Colors.END}")
    print(f"{Colors.CYAN}{'═'*55}{Colors.END}")
    
    input(f"{Colors.BLUE}\n    Press Enter to return to base...{Colors.END}")
    main()  

def main():
    while True:
        clear_screen()  
        print_logo()
        print_banner()
        print(f"{Colors.CYAN}{'─'*45}{Colors.END}")
        print(f"{Colors.BOLD}                    CONFIGURATION{Colors.END}")
        print(f"{Colors.CYAN}{'─'*45}{Colors.END}\n")
        
        try:
            webhook_url = input(f"{Colors.BLUE}    [?] Target Webhook URL > {Colors.END}")
            
            if not webhook_url.startswith('https://discord.com/api/webhooks/'):
                print(f"{Colors.YELLOW}    [!] Warning: URL doesn't look like a Discord webhook{Colors.END}")
            
            message = input(f"{Colors.BLUE}    [?] Message to send > {Colors.END}")
            count = int(input(f"{Colors.BLUE}    [?] Number of messages (1-100) > {Colors.END}"))
            
            if count > 100:
                print(f"{Colors.YELLOW}    [!] Capping at 100 messages to prevent rate limiting{Colors.END}")
                count = 100
            
            delay = int(input(f"{Colors.BLUE}    [?] Delay in MS (0-1000) > {Colors.END}"))
            
            if delay > 1000:
                print(f"{Colors.YELLOW}    [!] Capping delay at 1000ms{Colors.END}")
                delay = 1000
            elif delay < 0:
                delay = 0
            
            print(f"{Colors.GREEN}\n    ✓ Configuration accepted!{Colors.END}")
            time.sleep(1)
            send_webhook_message(webhook_url, message, count, delay)
            
        except ValueError:
            print(f"{Colors.RED}\n    [!] Invalid input! Please enter numbers only.{Colors.END}")
            time.sleep(2)
        except KeyboardInterrupt:
            print(f"{Colors.RED}\n\n    [!] Operation cancelled by user.{Colors.END}")
            break
        except Exception as e:
            print(f"{Colors.RED}\n    [!] Error: {str(e)}{Colors.END}")
            time.sleep(2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"{Colors.RED}\n\n    [!] Shutting down Tera Project...{Colors.END}")
        time.sleep(1)
