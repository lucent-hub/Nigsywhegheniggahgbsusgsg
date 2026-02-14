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
    print("╱╱╰╯╰━━┻╯╰╯╰╯ V0.2")
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
        "name": "DDos attack",
        "url": "https://fevber-die-plz.vercel.app/Projects/dd-attack.py",
    },
    {
        "key": "3",
        "name": "web lookup",
        "url": "https://fevber-die-plz.vercel.app/Projects/web_lookup.py",
    },
    {
        "key": "4",
        "name": "test",
        "url": "https://fevber-die-plz.vercel.app/Projects/test.py",
    }
]


# =========================
# ENSURE PIP + CORE TOOLS
# =========================
def ensure_environment():
    try:
        import pip
    except ImportError:
        subprocess.run([sys.executable, "-m", "ensurepip", "--upgrade"])

    subprocess.run(
        [sys.executable, "-m", "pip", "install", "--upgrade",
         "pip", "setuptools", "wheel"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )


# =========================
# FORCE DOWNLOAD (DELETE + UPDATE)
# =========================
def force_download(url):
    filename = os.path.basename(url)

    # Delete old file
    if os.path.exists(filename):
        try:
            os.remove(filename)
            print(f"[+] Deleted old {filename}")
        except:
            pass

    # Download fresh copy
    try:
        print(f"[+] Downloading fresh {filename}...")
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
        "platform", "socket", "hashlib"
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
# INSTALL MISSING
# =========================
def install_missing(modules):
    ensure_environment()

    missing = [m for m in modules if not is_installed(m)]

    if not missing:
        return

    print(f"[+] Installing: {', '.join(missing)}")

    subprocess.run(
        [sys.executable, "-m", "pip", "install", "--upgrade"] + missing
    )


# =========================
# RUN FILE
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
        print("lovely day")

        for p in projects:
            print(f"[{p['key']}] {p['name']}")

        print("[0] Exit\n")

        choice = input("Choose project: ").strip()

        if choice == "0":
            sys.exit(0)

        selected = next((p for p in projects if p["key"] == choice), None)

        if selected:
            file = force_download(selected["url"])

            if file and file.endswith(".py"):
                print("[+] Running latest version...\n")
                run_python_file(file)

            input("\nPress Enter to continue...")
        else:
            input("Invalid choice. Press Enter...")


# =========================
# START
# =========================
if __name__ == "__main__":
    menu()
