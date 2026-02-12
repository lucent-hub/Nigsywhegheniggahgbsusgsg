#!/usr/bin/env python3

import os
import sys
import subprocess
import urllib.request
import importlib.util
import re
import platform


# =========================
# LOGO
# =========================
def logo():
    print("╭━━━━╮")
    print("┃╭╮╭╮┃")
    print("╰╯┃┃┣┻━┳━┳━━╮")
    print("╱╱┃┃┃┃━┫╭┫╭╮┃")
    print("╱╱┃┃┃┃━┫┃┃╭╮┃")
    print("╱╱╰╯╰━━┻╯╰╯╰╯ V0.5")
    print()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


# =========================
# PROJECTS
# =========================
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
        "name": "Song attack",
        "url": "https://fevber-die-plz.vercel.app/Projects/dd-attack.py",
    }
]


# =========================
# SYSTEM PREP (Chromebook / Termux Safe)
# =========================
def system_prepare():
    # Upgrade pip tools safely
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "--upgrade",
         "pip", "setuptools", "wheel"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )


# =========================
# ENSURE PIP EXISTS
# =========================
def ensure_pip():
    try:
        import pip
    except ImportError:
        subprocess.run([sys.executable, "-m", "ensurepip", "--upgrade"])

    system_prepare()


# =========================
# DOWNLOAD FILE
# =========================
def download_file(url):
    filename = os.path.basename(url)

    try:
        print(f"[+] Downloading {filename}...")
        urllib.request.urlretrieve(url, filename)
        return filename
    except Exception as e:
        print(f"[!] Download failed: {e}")
        return None


# =========================
# EXTRACT IMPORTS
# =========================
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

    stdlib = {
        "os", "sys", "re", "subprocess", "math",
        "json", "time", "random", "shutil",
        "urllib", "threading", "asyncio",
        "platform", "socket", "hashlib",
        "itertools", "collections"
    }

    for m in matches:
        if m not in stdlib:
            imports.add(m)

    return imports


# =========================
# CHECK MODULE
# =========================
def is_installed(module):
    return importlib.util.find_spec(module) is not None


# =========================
# INSTALL MISSING MODULES
# =========================
def install_missing(modules):
    ensure_pip()

    missing = [m for m in modules if not is_installed(m)]

    if not missing:
        return

    print(f"[+] Installing: {', '.join(missing)}")

    subprocess.run(
        [sys.executable, "-m", "pip", "install", "--upgrade"] + missing
    )


# =========================
# RUN PYTHON FILE
# =========================
def run_python_file(filename):
    modules = extract_imports(filename)

    if modules:
        install_missing(modules)

    subprocess.run([sys.executable, filename])


# =========================
# MENU
# =========================
def menu():
    while True:
        os.system("clear" if os.name != "nt" else "cls")
        logo()

        print(f"System: {platform.system()} {platform.release()}\n")

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
            input("Invalid choice. Press Enter...")


# =========================
# START
# =========================
if __name__ == "__main__":
    menu()
