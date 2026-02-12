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
    print("╱╱╰╯╰━━┻╯╰╯╰╯ V0.2")
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


# Projects
projects = [
    {
        "key": "1",
        "name": "DDoS attack",
        "url": "https://fevber-die-plz.vercel.app/Projects/dd-attack.py",
        "deps": ""
    },
    {
        "key": "2",
        "name": "discord",
        "url": "https://fevber-die-plz.vercel.app/Projects/discord.py",
        "deps": ""
    },
    {
        "key": "3",
        "name": "web lookup",
        "url": "https://fevber-die-plz.vercel.app/Projects/web_lookup.py",
        "deps": ""
    }
]


# Ensure
def ensure_python():
    if shutil.which("pip"):
        return
    subprocess.run(["pkg", "install", "-y", "python"])


# Download
def download_file(url):
    filename = os.path.basename(url)
    try:
        urllib.request.urlretrieve(url, filename)
        return filename
    except:
        return None


# Extract
def extract_imports(filename):
    imports = set()
    with open(filename, "r", errors="ignore") as f:
        content = f.read()

    matches = re.findall(r'^\s*(?:import|from)\s+([a-zA-Z0-9_]+)', content, re.MULTILINE)

    for m in matches:
        imports.add(m)

    return imports


# Check
def is_installed(module):
    return importlib.util.find_spec(module) is not None


# Install
def install_missing(modules):
    ensure_python()
    missing = []

    for mod in modules:
        if not is_installed(mod):
            missing.append(mod)

    if not missing:
        return

    subprocess.run([sys.executable, "-m", "pip", "install"] + missing)


# Run
def run_python_file(filename):
    modules = extract_imports(filename)

    if modules:
        install_missing(modules)

    subprocess.run([sys.executable, filename])


# Menu
def menu():
    while True:
        os.system("clear")
        logo()

        for p in projects:
            print(f"[{p['key']}] {p['name']}")

        print("[0] Exit\n")

        choice = input("Choose project: ").strip()

        if choice == "0":
            sys.exit(0)

        selected = next((p for p in projects if p["key"] == choice), None)

        if selected:
            file = download_file(selected["url"])
            if file and file.endswith(".py"):
                run = input("Start now? (y/n): ").lower()
                if run == "y":
                    run_python_file(file)

            input("\nPress Enter to continue...")
        else:
            input("Invalid. Enter...")


# Start
if __name__ == "__main__":
    menu()
