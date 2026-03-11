#!/usr/bin/env python3

import os
import sys
import re
import time
import json
import socket
import shutil
import platform
import datetime
import threading
import subprocess
import importlib.util
import urllib.request
import urllib.parse
import glob
import select
import webbrowser

HOST = "127.0.0.1"
PORT = 8080
CFG = "tera_config.json"
PROJ_DIR = "projects"
PLUG_DIR = "plugins"
DATA_DIR = "data"
COLORS_DIR = "colors"
CONNECTIONS_FILE = "connections.json"
DEFAULTS_DIR = "defaults"

GH_USER = "lucent-hub"
GH_REPO = "Nigsywhegheniggahgbsusgsg"
GH_BRANCH = "main"
GH_PATH = "Projects"
CDN = "https://raw.githubusercontent.com"

DC_WEBHOOK = "https://discord.com/api/webhooks/1471348051854622913/ORsvlU3tbnIzo4SjLFDUpjtQnFvuNpWfZnpBJg-tmzZFZEAHGuVPhcPyEnMG-VMsFuvy"

COLORS = {
    "black": {"bg": "000000", "fg": "00ff00", "hl": "0000ff"},
    "midnight": {"bg": "191970", "fg": "87ceeb", "hl": "4b0082"},
    "dark": {"bg": "1a1a1a", "fg": "00ff00", "hl": "0000ff"},
    "amber": {"bg": "000000", "fg": "ffb000", "hl": "ff4500"},
    "matrix": {"bg": "000000", "fg": "39ff14", "hl": "00ff00"},
    "dracula": {"bg": "282a36", "fg": "f8f8f2", "hl": "bd93f9"},
    "solarized_dark": {"bg": "002b36", "fg": "839496", "hl": "b58900"},
    "solarized_light": {"bg": "fdf6e3", "fg": "657b83", "hl": "268bd2"},
    "gruvbox_dark": {"bg": "282828", "fg": "ebdbb2", "hl": "fabd2f"},
    "gruvbox_light": {"bg": "fbf1c7", "fg": "3c3836", "hl": "d79921"},
    "neon": {"bg": "0f0f0f", "fg": "ff00ff", "hl": "00ffff"},
    "ice": {"bg": "0a192f", "fg": "64ffda", "hl": "8892b0"},
    "rose": {"bg": "2e1a1f", "fg": "ff4d6d", "hl": "ffc2d1"},
    "hacker_red": {"bg": "000000", "fg": "ff0033", "hl": "990000"},
    "cyberpunk": {"bg": "1b1b2f", "fg": "ff00ff", "hl": "00ffff"},
    "midnight_blue": {"bg": "191970", "fg": "ffffff", "hl": "ff6347"},
    "forest": {"bg": "013220", "fg": "a8ff60", "hl": "008000"},
    "sunset": {"bg": "ff4500", "fg": "ffff00", "hl": "ff6347"},
    "ocean": {"bg": "001f3f", "fg": "7fdbff", "hl": "39cccc"},
    "desert": {"bg": "edc9af", "fg": "8b4513", "hl": "deb887"},
    "lava": {"bg": "330000", "fg": "ff3300", "hl": "ff6600"},
    "galaxy": {"bg": "0b0c10", "fg": "c5c6c7", "hl": "6f2232"},
    "plasma": {"bg": "2e003e", "fg": "ff00ff", "hl": "ffb6c1"},
    "aurora": {"bg": "001f3f", "fg": "39ff14", "hl": "00ffff"},
    "electric": {"bg": "0f0f0f", "fg": "ffff00", "hl": "ff00ff"},
    "midnight_purple": {"bg": "191970", "fg": "dda0dd", "hl": "9400d3"},
    "coffee": {"bg": "4b3621", "fg": "d2b48c", "hl": "a0522d"},
    "mint": {"bg": "98ff98", "fg": "006400", "hl": "00ff7f"},
    "coral": {"bg": "ff7f50", "fg": "000000", "hl": "ff6347"},
    "peach": {"bg": "ffe5b4", "fg": "ff4500", "hl": "ffa07a"},
    "storm": {"bg": "2f4f4f", "fg": "00ffff", "hl": "ff4500"},
    "iceberg": {"bg": "d0f0fd", "fg": "000080", "hl": "1e90ff"},
    "twilight": {"bg": "0c0032", "fg": "ff77ff", "hl": "ffb3ff"},
    "midnight_green": {"bg": "004953", "fg": "00ffcc", "hl": "008080"},
    "ruby": {"bg": "9b111e", "fg": "ffffff", "hl": "ff0000"},
    "sapphire": {"bg": "0f52ba", "fg": "ffffff", "hl": "00ffff"},
    "emerald": {"bg": "50c878", "fg": "000000", "hl": "00ff00"},
    "topaz": {"bg": "ffc87c", "fg": "000000", "hl": "ff8c00"},
    "onyx": {"bg": "353839", "fg": "ffffff", "hl": "ff00ff"},
    "amethyst": {"bg": "9966cc", "fg": "ffffff", "hl": "8a2be2"},
    "copper": {"bg": "b87333", "fg": "000000", "hl": "ff7f50"},
    "bronze": {"bg": "cd7f32", "fg": "000000", "hl": "ffd700"},
    "platinum": {"bg": "e5e4e2", "fg": "000000", "hl": "ffffff"},
    "jade": {"bg": "00a86b", "fg": "ffffff", "hl": "00ff7f"},
    "obsidian": {"bg": "0b0b0b", "fg": "ffffff", "hl": "ff0000"},
    "ivory": {"bg": "fffff0", "fg": "000000", "hl": "dcdcdc"},
}

DEFAULT_COLORS = {
    "red": {"bg": "ff0000", "fg": "ffffff", "hl": "000000"},
    "blue": {"bg": "0000ff", "fg": "ffffff", "hl": "ffff00"},
    "green": {"bg": "00ff00", "fg": "000000", "hl": "ffffff"},
    "purple": {"bg": "800080", "fg": "ffffff", "hl": "00ff00"},
    "orange": {"bg": "ffa500", "fg": "000000", "hl": "0000ff"},
    "cyan": {"bg": "00ffff", "fg": "000000", "hl": "ff00ff"},
    "pink": {"bg": "ffc0cb", "fg": "000000", "hl": "ff69b4"},
    "lime": {"bg": "32cd32", "fg": "000000", "hl": "ffffff"},
    "gold": {"bg": "ffd700", "fg": "000000", "hl": "b8860b"},
    "teal": {"bg": "008080", "fg": "ffffff", "hl": "00ffff"},
    "navy": {"bg": "000080", "fg": "ffffff", "hl": "87cefa"},
    "crimson": {"bg": "dc143c", "fg": "ffffff", "hl": "8b0000"},
    "violet": {"bg": "ee82ee", "fg": "000000", "hl": "9400d3"},
    "brown": {"bg": "8b4513", "fg": "ffffff", "hl": "d2b48c"},
    "silver": {"bg": "c0c0c0", "fg": "000000", "hl": "808080"},
    "charcoal": {"bg": "36454f", "fg": "ffffff", "hl": "00ffcc"},
    "maroon": {"bg": "800000", "fg": "ffffff", "hl": "ff4500"},
    "olive": {"bg": "808000", "fg": "000000", "hl": "ffff00"},
    "orchid": {"bg": "da70d6", "fg": "000000", "hl": "9400d3"},
    "salmon": {"bg": "fa8072", "fg": "000000", "hl": "ff4500"},
    "turquoise": {"bg": "40e0d0", "fg": "000000", "hl": "00ced1"},
    "plum": {"bg": "dda0dd", "fg": "000000", "hl": "800080"},
    "peru": {"bg": "cd853f", "fg": "ffffff", "hl": "8b4513"},
    "khaki": {"bg": "f0e68c", "fg": "000000", "hl": "bdb76b"},
    "lavender": {"bg": "e6e6fa", "fg": "000000", "hl": "9370db"},
    "cerulean": {"bg": "007ba7", "fg": "ffffff", "hl": "00ffff"},
    "apricot": {"bg": "fbceb1", "fg": "000000", "hl": "ff7f50"},
    "jade": {"bg": "00a86b", "fg": "ffffff", "hl": "00ff7f"},
    "pearl": {"bg": "eae0c8", "fg": "000000", "hl": "dcdcdc"},
    "onyx": {"bg": "353839", "fg": "ffffff", "hl": "ff00ff"},
}

def get_colors():
    system = platform.system().lower()
    release = platform.release().lower()
    
    if system == "darwin":
        return COLORS.get("midnight", COLORS["midnight"])
    elif system == "windows":
        if "10" in release or "11" in release:
            return COLORS.get("dracula", COLORS["dracula"])
        else:
            return COLORS.get("black", COLORS["black"])
    elif system == "linux":
        try:
            with open("/etc/os-release") as f:
                data = f.read().lower()
            if "ubuntu" in data:
                return COLORS.get("solarized_light", COLORS["solarized_light"])
            elif "arch" in data:
                return COLORS.get("matrix", COLORS["matrix"])
            elif "fedora" in data:
                return COLORS.get("gruvbox_dark", COLORS["gruvbox_dark"])
            elif "debian" in data:
                return COLORS.get("solarized_dark", COLORS["solarized_dark"])
            elif "manjaro" in data:
                return COLORS.get("neon", COLORS["neon"])
            else:
                return COLORS.get("dark", COLORS["dark"])
        except:
            return COLORS.get("dark", COLORS["dark"])
    else:
        return COLORS.get("black", COLORS["black"])

CURRENT_COLORS = get_colors()

CFG_DEFAULT = {
    "name": "Tera System",
    "version": "7.0",
    "author": "system",
    "projects": [],
    "settings": {
        "theme": "dark",
        "auto_save": True,
        "debug": False
    },
    "paths": {
        "projects": PROJ_DIR,
        "plugins": PLUG_DIR,
        "data": DATA_DIR,
        "colors": COLORS_DIR,
        "defaults": DEFAULTS_DIR
    }
}

try:
    import psutil
except ImportError:
    psutil = None

class FileManager:
    def __init__(self):
        self.create_dirs()
        self.create_defaults()
    
    def create_dirs(self):
        for d in [PROJ_DIR, PLUG_DIR, DATA_DIR, COLORS_DIR, DEFAULTS_DIR]:
            os.makedirs(d, exist_ok=True)
    
    def create_defaults(self):
        colors_file = os.path.join(DEFAULTS_DIR, "colors.json")
        if not os.path.exists(colors_file):
            with open(colors_file, 'w') as f:
                json.dump(DEFAULT_COLORS, f, indent=2)
        
        cfg_file = os.path.join(DEFAULTS_DIR, "config.json")
        if not os.path.exists(cfg_file):
            with open(cfg_file, 'w') as f:
                json.dump(CFG_DEFAULT, f, indent=2)
        
        plugin_file = os.path.join(DEFAULTS_DIR, "plugin_template.py")
        if not os.path.exists(plugin_file):
            with open(plugin_file, 'w') as f:
                f.write('''class Plugin:
    def __init__(self):
        self.name = "template"
        self.version = "1.0"
        self.author = "user"
        self.description = "default plugin"
    
    def run(self, project=None, data=None, color="default"):
        print(f"=== {self.name} ===\\n")
        print(f"Project: {project}")
        print(f"Color: {color}")
        print(f"Data: {data}")
        print("Hello from plugin!")
    
    def on_load(self):
        print(f"[{self.name}] Plugin loaded")
    
    def on_menu(self):
        print(f"[{self.name}] Ready")
''')
        
        color_sh_file = os.path.join(DEFAULTS_DIR, "color.sh")
        if not os.path.exists(color_sh_file):
            with open(color_sh_file, 'w') as f:
                f.write('''#!/bin/bash
# Default color configuration
color = "dark"
''')
    
    def list_files(self, directory, ext=None):
        if ext:
            return glob.glob(f"{directory}/*.{ext}")
        return glob.glob(f"{directory}/*")
    
    def read_json(self, path):
        try:
            with open(path, 'r') as f:
                return json.load(f)
        except:
            return {}
    
    def write_json(self, path, data):
        try:
            with open(path, 'w') as f:
                json.dump(data, f, indent=2)
            return True
        except:
            return False
    
    def read_file(self, path):
        try:
            with open(path, 'r') as f:
                return f.read()
        except:
            return ""
    
    def write_file(self, path, content):
        try:
            with open(path, 'w') as f:
                f.write(content)
            return True
        except:
            return False
    
    def update_color_sh(self, color_name):
        path = os.path.join(DEFAULTS_DIR, "color.sh")
        content = f'''#!/bin/bash
# Current color configuration
color = "{color_name}"
'''
        self.write_file(path, content)

fm = FileManager()

class Connections:
    def __init__(self):
        self.file = CONNECTIONS_FILE
        self.data = self.load()
        
    def load(self):
        return fm.read_json(self.file)
    
    def save(self):
        fm.write_json(self.file, self.data)
    
    def connect(self, plugin, project, color=None):
        if plugin not in self.data:
            self.data[plugin] = {}
        self.data[plugin][project] = color or "default"
        self.save()
    
    def disconnect(self, plugin, project):
        if plugin in self.data and project in self.data[plugin]:
            del self.data[plugin][project]
            self.save()
    
    def get_for_plugin(self, plugin):
        return self.data.get(plugin, {})
    
    def get_for_project(self, project):
        connected = []
        for plugin, projects in self.data.items():
            if project in projects:
                connected.append((plugin, projects[project]))
        return connected

conn = Connections()

class GitHubProjects:
    def __init__(self):
        self.cache = []
        self.cache_time = 0
        
    def get_raw_url(self, filename):
        return f"{CDN}/{GH_USER}/{GH_REPO}/{GH_BRANCH}/{GH_PATH}/{filename}"
    
    def get_api_url(self):
        return f"https://api.github.com/repos/{GH_USER}/{GH_REPO}/contents/{GH_PATH}?ref={GH_BRANCH}"
    
    def fetch(self):
        now = time.time()
        if now - self.cache_time < 300:
            return self.cache
            
        try:
            url = self.get_api_url()
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=3) as r:
                data = json.loads(r.read().decode())
                self.cache = []
                for item in data:
                    if item['name'].endswith('.py'):
                        self.cache.append({
                            'n': item['name'],
                            'u': self.get_raw_url(item['name'])
                        })
                self.cache_time = now
                return self.cache
        except:
            return self.cache
    
    def list(self):
        return self.fetch()

gh = GitHubProjects()

class Discord:
    def __init__(self, webhook):
        self.webhook = webhook
    
    def send(self, msg, user="system"):
        try:
            data = {
                "content": f"**[{user}]** {msg}",
                "username": "Tera System"
            }
            data = json.dumps(data).encode()
            req = urllib.request.Request(self.webhook, data=data, method="POST")
            req.add_header("Content-Type", "application/json")
            urllib.request.urlopen(req, timeout=3)
            return True
        except:
            return False

dc = Discord(DC_WEBHOOK)

class Config:
    def __init__(self, f=CFG):
        self.f = f
        self.c = self.load()
        
    def load(self):
        default = fm.read_json(os.path.join(DEFAULTS_DIR, "config.json")) or CFG_DEFAULT
        if os.path.exists(self.f):
            try:
                user = fm.read_json(self.f)
                for k, v in user.items():
                    default[k] = v
            except:
                pass
        return default
    
    def save(self):
        fm.write_json(self.f, self.c)
        fm.update_color_sh(self.c['settings']['theme'])
    
    def get_proj(self):
        p = []
        
        for f in fm.list_files(PROJ_DIR, 'py'):
            n = os.path.basename(f)
            p.append({'n': n, 'path': f, 'local': True})
        
        for g in gh.list():
            if not any(x.get('n') == g['n'] for x in p):
                p.append({'n': g['n'], 'u': g['u']})
        
        return p
    
    def set_theme(self, t):
        if t in COLORS:
            self.c['settings']['theme'] = t
            self.save()

class PluginMgr:
    def __init__(self):
        self.p = {}
        self.files = {}
        self.colors = {}
        self.load()
        self.load_colors()
    
    def load_colors(self):
        self.colors = COLORS.copy()
        for f in fm.list_files(COLORS_DIR, 'json'):
            try:
                name = os.path.basename(f)[:-5]
                data = fm.read_json(f)
                self.colors[name] = data
            except:
                pass
    
    def save_color(self, name, data):
        path = os.path.join(COLORS_DIR, f"{name}.json")
        if fm.write_json(path, data):
            self.colors[name] = data
            return True
        return False
    
    def delete_color(self, name):
        if name in self.colors and name not in COLORS:
            path = os.path.join(COLORS_DIR, f"{name}.json")
            try:
                os.remove(path)
                del self.colors[name]
                return True
            except:
                pass
        return False
    
    def load(self):
        self.p = {}
        self.files = {}
        sys.path.insert(0, os.path.abspath(PLUG_DIR))
        
        for f in fm.list_files(PLUG_DIR, 'py'):
            if f.endswith('__init__.py'):
                continue
            m = os.path.basename(f)[:-3]
            try:
                spec = importlib.util.spec_from_file_location(m, f)
                mod = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(mod)
                if hasattr(mod, 'Plugin'):
                    plugin = mod.Plugin()
                    plugin.path = f
                    plugin.file = os.path.basename(f)
                    plugin.name = getattr(plugin, 'name', m)
                    plugin.version = getattr(plugin, 'version', '1.0')
                    plugin.author = getattr(plugin, 'author', 'unknown')
                    self.p[m] = plugin
                    
                    data_file = os.path.join(DATA_DIR, f"{m}.json")
                    self.files[m] = fm.read_json(data_file)
            except Exception as e:
                pass
    
    def save_data(self, name):
        if name in self.files:
            path = os.path.join(DATA_DIR, f"{name}.json")
            fm.write_json(path, self.files[name])
    
    def run(self, name, project=None):
        if name in self.p:
            plugin = self.p[name]
            if hasattr(plugin, 'run'):
                try:
                    if project:
                        connected = conn.get_for_plugin(name)
                        color = connected.get(project, "default")
                        print(f"\n[{name}] Running with {project} [{color}]\n")
                        plugin.run(project, self.files.get(name, {}), color)
                    else:
                        print(f"\n[{name}] Running\n")
                        plugin.run(None, self.files.get(name, {}), "default")
                    self.save_data(name)
                except Exception as e:
                    print(f"[-] Error: {e}")
            else:
                print("[*] No run() method")
        else:
            print(f"[-] Not found")
    
    def edit(self, name):
        if name in self.p:
            path = self.p[name].path
            editor = os.environ.get('EDITOR', 'nano')
            try:
                subprocess.run([editor, path])
                self.load()
            except:
                print(f"[-] Failed to open {editor}")
        else:
            print(f"[-] Not found")
    
    def view_data(self, name):
        if name in self.files:
            print(f"\nDATA for {name}:")
            print(json.dumps(self.files[name], indent=2))
        else:
            print("[-] No data")
    
    def edit_data(self, name):
        if name in self.files:
            print(f"\nEDIT DATA for {name} (key=value format, empty to stop):")
            while True:
                kv = input("key=value: ").strip()
                if not kv:
                    break
                if '=' in kv:
                    k, v = kv.split('=', 1)
                    self.files[name][k] = v
                    self.save_data(name)
                    print(f"[+] Set {k}={v}")
        else:
            self.files[name] = {}
            self.edit_data(name)
    
    def remove(self, name):
        if name in self.p:
            path = self.p[name].path
            try:
                os.remove(path)
                print(f"[+] Removed {name}")
                self.load()
            except:
                print(f"[-] Failed to remove")
        else:
            print(f"[-] Not found")
    
    def install(self, url):
        try:
            f = os.path.basename(url).split('?')[0]
            if not f.endswith('.py'):
                f = f + '.py'
            path = os.path.join(PLUG_DIR, f)
            
            stop = threading.Event()
            t = threading.Thread(target=spinner, args=(stop, "installing"))
            t.start()
            
            if shutil.which("wget"):
                subprocess.run(["wget", "-O", path, url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            elif shutil.which("curl"):
                subprocess.run(["curl", "-L", "-o", path, url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                urllib.request.urlretrieve(url, path)
            
            stop.set()
            t.join()
            
            if os.path.exists(path):
                print(f"[+] Installed: {f}")
                self.load()
                return True
        except:
            stop.set()
            t.join()
            print("[-] Failed")
        return False
    
    def new(self):
        print("\nNEW PLUGIN")
        name = input("name: ").strip()
        if not name:
            return
        if not name.endswith('.py'):
            name = name + '.py'
        
        template = fm.read_file(os.path.join(DEFAULTS_DIR, "plugin_template.py"))
        template = template.replace('"template"', f'"{name[:-3]}"')
        
        path = os.path.join(PLUG_DIR, name)
        if fm.write_file(path, template):
            print(f"[+] Created: {path}")
            self.load()
            return path
        return None
    
    def example(self):
        url = "https://raw.githubusercontent.com/lucent-hub/Nigsywhegheniggahgbsusgsg/main/Projects/example_plugin.py"
        return self.install(url)
    
    def hook(self, h, *a, **k):
        r = []
        for n, p in self.p.items():
            if hasattr(p, h):
                try:
                    x = getattr(p, h)(*a, **k)
                    if x:
                        r.append(x)
                except:
                    pass
        return r

def clear():
    os.system("cls" if os.name == "nt" else "clear")

def set_bg(color_hex):
    r, g, b = hex_to_rgb(color_hex)
    print(f"\033[48;2;{r};{g};{b}m", end="")

def set_fg(color_hex):
    r, g, b = hex_to_rgb(color_hex)
    print(f"\033[38;2;{r};{g};{b}m", end="")

def reset_colors():
    print("\033[0m", end="")

def colored_logo(theme):
    set_bg(theme['bg'])
    set_fg(theme['hl'])
    print(" ╭━━━━╮")
    set_fg(theme['fg'])
    print(" ┃╭╮╭╮┃")
    print(" ╰╯┃┃┣┻━┳━┳━━╮")
    print(" ╱╱┃┃┃┃━┫╭┫╭╮┃")
    print(" ╱╱┃┃┃┃━┫┃┃╭╮┃")
    print(" ╱╱╰╯╰━━┻╯╰╯╰╯   v7")
    set_fg(theme['fg'])
    print("────────────────────────────")
    reset_colors()

def local_ip():
    try:
        return socket.gethostbyname(socket.gethostname())
    except:
        return "?"

def public_ip():
    try:
        with urllib.request.urlopen("https://api.ipify.org?format=json", timeout=2) as r:
            return json.loads(r.read().decode()).get("ip", "?")
    except:
        return "?"

def uptime():
    if psutil:
        try:
            b = datetime.datetime.fromtimestamp(psutil.boot_time())
            d = datetime.datetime.now() - b
            return str(d).split(".")[0]
        except:
            pass
    return "?"

def ram_total():
    if psutil:
        try:
            mem = psutil.virtual_memory()
            return f"{mem.total / 1e9:.1f} GB"
        except:
            pass
    return "?"

def cpu_model():
    if psutil:
        try:
            return platform.processor() or "?"
        except:
            pass
    return "?"

def hex_to_rgb(hex_color):
    if not hex_color or len(hex_color) != 6:
        return 0, 255, 0
    try:
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        return r, g, b
    except:
        return 0, 255, 0

def panel(c, pm):
    clear()
    
    theme_name = c.c['settings']['theme']
    theme = COLORS.get(theme_name, CURRENT_COLORS)
    
    set_bg(theme['bg'])
    colored_logo(theme)
    set_fg(theme['fg'])
    
    proj = c.get_proj()
    
    color_sh_content = fm.read_file(os.path.join(DEFAULTS_DIR, "color.sh"))
    color_line = ""
    for line in color_sh_content.split('\n'):
        if 'color =' in line:
            color_line = line.strip()
            break
    
    print("|")
    print("| OS")
    print(f"|  +- System  : {platform.system()} {platform.release()}")
    print(f"|  +- Arch    : {platform.machine()}")
    print(f"|  +- CPU     : {cpu_model()}")
    print(f"|  +- RAM     : {ram_total()}")
    print(f"|  +- Python  : {platform.python_version()}")
    print(f"|  +- Uptime  : {uptime()}")
    print("|")
    print(f"| CWD        : {os.getcwd()}")
    print(f"| Plugins    : {len(pm.p)}")
    print(f"| Theme      : {theme_name}")
    print(f"| {color_line}")
    print("+---------------------------")
    print("[--------]<FILES>[---------]")
    print(f"| Projects dir : {PROJ_DIR}/")
    print(f"| Plugins dir  : {PLUG_DIR}/")
    print(f"| Data dir     : {DATA_DIR}/")
    print(f"| Defaults dir : {DEFAULTS_DIR}/")
    print("[--------]<PLUGINS>[---------]")
    plugin_output = pm.hook('on_menu')
    if plugin_output:
        for out in plugin_output:
            if out:
                print(out)
    else:
        for name, plugin in pm.p.items():
            if hasattr(plugin, 'on_menu'):
                try:
                    plugin.on_menu()
                except:
                    pass
    print("+---------------------------")
    print("| PROJECTS")
    if proj:
        for i,p in enumerate(proj,1):
            if p.get('local'):
                t = "L"
            else:
                t = "R"
            connected = conn.get_for_project(p['n'])
            if connected:
                conn_str = " [" + ",".join([c[0] for c in connected]) + "]"
            else:
                conn_str = ""
            print(f"|  {t} {i:<2} | {p['n']}{conn_str}")
    else:
        print("|  No projects")
    print("|_________________")
    print("+-- P  | PLUGINS")
    print("+-- C  | CONFIG")
    print("+-- F  | FILES")
    print("+-- S  | SUGGEST")
    print("+-- 0  | EXIT")
    print("-------------")
    reset_colors()

def files_menu():
    while True:
        clear()
        print("+--- FILE MANAGER")
        print("|")
        print("| DIRECTORIES:")
        print(f"|  1. {PROJ_DIR}/")
        print(f"|  2. {PLUG_DIR}/")
        print(f"|  3. {DATA_DIR}/")
        print(f"|  4. {DEFAULTS_DIR}/")
        print("|")
        print("+-- 1-4 | LIST FILES")
        print("+-- 0   | BACK")
        print("-------------")
        
        ch = input("> ").strip()
        if ch == "0":
            break
        elif ch in ["1","2","3","4"]:
            dirs = [PROJ_DIR, PLUG_DIR, DATA_DIR, DEFAULTS_DIR]
            d = dirs[int(ch)-1]
            files = fm.list_files(d)
            if files:
                print(f"\nFILES in {d}/:")
                for i,f in enumerate(files,1):
                    print(f"  {i}. {os.path.basename(f)}")
            else:
                print(f"\nEmpty directory")
            input("\nENTER...")

def suggestion_mode(c, pm):
    clear()
    print("+--- SUGGESTION MODE")
    print("| Type your message and press Enter")
    print("| Messages sent to Discord")
    print("| Type 'back' to return")
    print("+---------------------------")
    
    while True:
        msg = input("\n> ").strip()
        if msg.lower() == "back":
            break
        if msg:
            pm.hook('on_suggest', msg)
            if dc.send(msg, user="system"):
                print("[+] Sent")
            else:
                print("[-] Failed")

def spinner(stop, msg):
    while not stop.is_set():
        for x in "/-\\|":
            print(f"\r{msg} {x}", end="")
            time.sleep(0.1)
            if stop.is_set():
                break
    print(f"\r{msg} +")

def ensure_pip():
    try:
        import pip
    except:
        subprocess.run([sys.executable, "-m", "ensurepip"])
    subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "pip", "setuptools", "wheel"],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def get_imports(f):
    i = set()
    try:
        with open(f, 'r', errors='ignore') as f:
            c = f.read()
    except:
        return i
    m = re.findall(r'^\s*(?:import|from)\s+([a-zA-Z0-9_]+)', c, re.MULTILINE)
    std = {'os','sys','re','subprocess','math','json','time','random','shutil','urllib','threading','platform','socket'}
    for x in m:
        if x not in std:
            i.add(x)
    return i

def check(mod):
    return importlib.util.find_spec(mod) is not None

def install(mods):
    ensure_pip()
    miss = [m for m in mods if not check(m)]
    if not miss:
        return
    stop = threading.Event()
    t = threading.Thread(target=spinner, args=(stop, "install"))
    t.start()
    subprocess.run([sys.executable, "-m", "pip", "install"] + miss,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    stop.set()
    t.join()

def dl(url):
    f = os.path.basename(url).split('?')[0]
    if os.path.exists(f):
        os.remove(f)
    stop = threading.Event()
    t = threading.Thread(target=spinner, args=(stop, "fetch"))
    t.start()
    try:
        if shutil.which("wget"):
            subprocess.run(["wget", "-O", f, url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        elif shutil.which("curl"):
            subprocess.run(["curl", "-L", "-o", f, url], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            urllib.request.urlretrieve(url, f)
        stop.set()
        t.join()
        return f
    except:
        stop.set()
        t.join()
        return None

def run(f):
    i = get_imports(f)
    if i:
        install(i)
    subprocess.run([sys.executable, f])

def plugin_menu(pm, proj):
    while True:
        clear()
        print("+--- PLUGIN MANAGER")
        print("|")
        print(f"| LOADED: {len(pm.p)}")
        print("|")
        if pm.p:
            for i,(n,pl) in enumerate(pm.p.items(),1):
                v = getattr(pl, 'version', '1.0')
                a = getattr(pl, 'author', '?')
                connected = conn.get_for_plugin(n)
                if connected:
                    conn_str = " [" + ",".join(connected.keys()) + "]"
                else:
                    conn_str = ""
                print(f"|  {i}. {n} v{v} by {a}{conn_str}")
        else:
            print("|  No plugins")
        print("|")
        print("+-- I  | INSTALL (URL)")
        print("+-- R  | RUN PLUGIN")
        print("+-- C  | CONNECT TO PROJECT")
        print("+-- D  | DISCONNECT")
        print("+-- V  | VIEW DATA")
        print("+-- E  | EDIT DATA")
        print("+-- N  | EDIT CODE (nano)")
        print("+-- X  | DELETE")
        print("+-- W  | NEW")
        print("+-- M  | EXAMPLE")
        print("+-- L  | RELOAD")
        print("+-- 0  | BACK")
        print("-------------")
        
        ch = input("> ").strip().lower()
        if ch == "0":
            break
        elif ch == "i":
            url = input("raw url: ").strip()
            if url:
                pm.install(url)
                input("\nENTER...")
        elif ch == "r":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    idx = int(input("\nnumber: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        print("\nPROJECTS:")
                        for i,p in enumerate(proj,1):
                            print(f"  {i}. {p['n']}")
                        pidx = int(input("project number (0 for none): ")) - 1
                        if pidx >= 0 and pidx < len(proj):
                            project = proj[pidx]['n']
                        else:
                            project = None
                        print("")
                        pm.run(name, project)
                    else:
                        print("[-] Invalid")
                except:
                    print("[-] Invalid")
            else:
                print("[-] No plugins")
            input("\nENTER...")
        elif ch == "c":
            if pm.p and proj:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    pidx = int(input("plugin number: ")) - 1
                    if 0 <= pidx < len(pm.p):
                        name = list(pm.p.keys())[pidx]
                        print("\nPROJECTS:")
                        for i,p in enumerate(proj,1):
                            print(f"  {i}. {p['n']}")
                        pjidx = int(input("project number: ")) - 1
                        if 0 <= pjidx < len(proj):
                            project = proj[pjidx]['n']
                            print("\nCOLORS:")
                            colors = list(pm.colors.keys())
                            for i,c in enumerate(colors,1):
                                print(f"  {i}. {c}")
                            cidx = int(input("color number (0 for default): ")) - 1
                            if cidx >= 0 and cidx < len(colors):
                                color = colors[cidx]
                            else:
                                color = "default"
                            conn.connect(name, project, color)
                            print(f"[+] Connected {name} -> {project} [{color}]")
                except:
                    pass
            else:
                print("[-] Need plugins and projects")
            input("\nENTER...")
        elif ch == "d":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    connected = conn.get_for_plugin(n)
                    if connected:
                        print(f"  {i}. {n} -> {list(connected.keys())}")
                try:
                    idx = int(input("plugin number: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        connected = conn.get_for_plugin(name)
                        if connected:
                            print(f"\nCONNECTIONS for {name}:")
                            conns = list(connected.keys())
                            for i,proj in enumerate(conns,1):
                                print(f"  {i}. {proj}")
                            cidx = int(input("connection number: ")) - 1
                            if 0 <= cidx < len(conns):
                                project = conns[cidx]
                                conn.disconnect(name, project)
                                print(f"[-] Disconnected {name} -> {project}")
                except:
                    pass
            input("\nENTER...")
        elif ch == "v":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        pm.view_data(name)
                except:
                    pass
            input("\nENTER...")
        elif ch == "e":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        pm.edit_data(name)
                except:
                    pass
            input("\nENTER...")
        elif ch == "n":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        pm.edit(name)
                except:
                    pass
            else:
                print("[-] No plugins")
            input("\nENTER...")
        elif ch == "x":
            if pm.p:
                print("\nPLUGINS:")
                for i,(n,pl) in enumerate(pm.p.items(),1):
                    print(f"  {i}. {n}")
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(pm.p):
                        name = list(pm.p.keys())[idx]
                        confirm = input(f"remove {name}? (y/n): ")
                        if confirm.lower() == 'y':
                            pm.remove(name)
                    else:
                        print("[-] Invalid")
                except:
                    print("[-] Invalid")
            else:
                print("[-] No plugins")
            input("\nENTER...")
        elif ch == "w":
            pm.new()
            input("\nENTER...")
        elif ch == "m":
            if pm.example():
                print("[+] Example installed")
            else:
                print("[-] Failed")
            input("\nENTER...")
        elif ch == "l":
            pm.load()
            print("[+] Reloaded")
            input("\nENTER...")

def config_menu(c):
    while True:
        clear()
        print("+--- CONFIG MANAGER")
        print("|")
        print(f"| Name    : {c.c.get('name', 'Tera')}")
        print(f"| Version : {c.c.get('version', '7.0')}")
        print(f"| Theme   : {c.c['settings']['theme']}")
        print(f"| Debug   : {c.c['settings'].get('debug', False)}")
        print("|")
        print("+-- T  | THEMES")
        print("+-- D  | TOGGLE DEBUG")
        print("+-- 0  | BACK")
        print("-------------")
        
        ch = input("> ").strip().lower()
        if ch == "0":
            break
        elif ch == "t":
            print("\nTHEMES:")
            for t in COLORS:
                print(f"  - {t}")
            t = input("\ntheme: ").strip().lower()
            if t in COLORS:
                c.set_theme(t)
        elif ch == "d":
            c.c['settings']['debug'] = not c.c['settings'].get('debug', False)
            c.save()

def main():
    c = Config()
    pm = PluginMgr()
    pm.hook('on_load')
    fm.update_color_sh(c.c['settings']['theme'])
    
    while True:
        proj = c.get_proj()
        panel(c, pm)
        
        ch = input("> ").strip()
        
        if ch == "0":
            sys.exit(0)
        elif ch.lower() == "p":
            plugin_menu(pm, proj)
        elif ch.lower() == "c":
            config_menu(c)
        elif ch.lower() == "f":
            files_menu()
        elif ch.lower() == "s":
            suggestion_mode(c, pm)
        elif ch.isdigit():
            i = int(ch) - 1
            if 0 <= i < len(proj):
                p = proj[i]
                pm.hook('on_run', p['n'])
                if p.get('local'):
                    run(p['path'])
                else:
                    f = dl(p['u'])
                    if f and f.endswith('.py'):
                        run(f)
                input("\n[+] DONE. ENTER...")

if __name__ == "__main__":
    main()
