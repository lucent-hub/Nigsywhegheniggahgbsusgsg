#!/usr/bin/env python3

import os
import sys
import subprocess
import urllib.request
import importlib.util
import re
import shutil


# Logo
def logo():
    print("╭━━━━╮")
    print("┃╭╮╭╮┃")
    print("╰╯┃┃┣┻━┳━┳━━╮")
    print("╱╱┃┃┃┃━┫╭┫╭╮┃")
    print("╱╱┃┃┃┃━┫┃┃╭╮┃")
    print("╱╱╰╯╰━━┻╯╰╯╰╯ V0.3")
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


# Projects
projects = [
    {
        "key": "1",
        "name": "discord",
        "url": "https://fevber-die-plz.vercel.app/Projects/discord.py",
    },
    {
        "key": "2",
        "name": "web lookup",
        "url": "https://fevber-die-plz.vercel.app/Projects/web_lookup.py",
    },
    {
        "key": "3",
        "name": "DDoS attack",
        "https://fevber-die-plz.vercel.app/Projects/dd-attack.py": None,  
    }
]


# Ensure pip exists
def ensure_pip():
    try:
        import pip  # noqa
    except ImportError:
        print("[!] pip not found. Installing pip...")
        subprocess.run([sys.executable, "-m", "ensurepip", "--upgrade"])


# Download file
def download_file(url):
    filename = os.path.basename(url)
    try:
        urllib.request.urlretrieve(url, filename)
        return filename
    except Exception as e:
        print(f"[!] Download failed: {e}")
        return None


# Extract imports
def extract_imports(filename):
    imports = set()

    try:
        with open(filename, "r", errors="ignore") as f:
            content = f.read()
    except:
        return imports

    matches = re.findall(
        r'^\s*(?:import|from)\s+([a-zA-Z0-9_]+)',
        content,
        re.MULTILINE
    )

    builtins = {
        "os", "sys", "re", "subprocess", "math",
        "json", "time", "random", "shutil",
        "urllib", "threading", "asyncio"
    }

    for m in matches:
        if m not in builtins:
            imports.add(m)

    return imports


# Check installed
def is_installed(module):
    return importlib.util.find_spec(module) is not None


# Install missing modules
def install_missing(modules):
    ensure_pip()
    missing = [m for m in modules if not is_installed(m)]

    if not missing:
        return

    print(f"[+] Installing missing modules: {', '.join(missing)}")
    subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade"] + missing)


# Run file
def run_python_file(filename):
    modules = extract_imports(filename)

    if modules:
        install_missing(modules)

    subprocess.run([sys.executable, filename])


# Menu
def menu():
    while True:
        os.system("clear" if os.name != "nt" else "cls")
        logo()

        for p in projects:
            print(f"[{p['key']}] {p['name']}")

        print("[0] Exit\n")

        choice = input("Choose project: ").strip()

        if choice == "0":
            sys.exit(0)

        selected = next((p for p in projects if p["key"] == choice), None)

        if selected:

            # If test project (no URL)
            if selected["url"] is None:
                test_file = "test_script.py"
                with open(test_file, "w") as f:
                    f.write("print('Test project running successfully!')\n")
                file = test_file
            else:
                file = download_file(selected["url"])

            if file and file.endswith(".py"):
                run = input("Start now? (y/n): ").lower()
                if run == "y":
                    run_python_file(file)

            input("\nPress Enter to continue...")
        else:
            input("Invalid. Press Enter...")


if __name__ == "__main__":
    menu()
