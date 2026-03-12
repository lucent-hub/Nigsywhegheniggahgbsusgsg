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
CONNECTIONS_FILE = "connections.json"
DEFAULTS_DIR = "defaults"

U1 = "lucent-hub"
U2 = "Nigsywhegheniggahgbsusgsg"
U3 = "main"
U4 = "Projects"
U5 = "https://fevber-die-plz.vercel.app"
U6 = "https://pastebin.com/raw/QuYcbyLm"

C = {
    "black": "30",
    "red": "31",
    "green": "32",
    "yellow": "33",
    "blue": "34",
    "magenta": "35",
    "cyan": "36",
    "white": "37",
    "bright_black": "90",
    "bright_red": "91",
    "bright_green": "92",
    "bright_yellow": "93",
    "bright_blue": "94",
    "bright_magenta": "95",
    "bright_cyan": "96",
    "bright_white": "97"
}

T = {
    "black": "black",
    "midnight": "bright_blue",
    "dark": "bright_green",
    "amber": "bright_yellow",
    "matrix": "bright_green",
    "dracula": "bright_magenta",
    "solarized_dark": "bright_blue",
    "solarized_light": "bright_yellow",
    "gruvbox_dark": "bright_yellow",
    "gruvbox_light": "bright_black",
    "neon": "bright_magenta",
    "ice": "bright_cyan",
    "rose": "bright_red",
    "hacker_red": "bright_red",
    "cyberpunk": "bright_magenta",
    "midnight_blue": "bright_white",
    "forest": "bright_green",
    "sunset": "bright_yellow",
    "ocean": "bright_blue",
    "desert": "bright_yellow",
    "lava": "bright_red",
    "galaxy": "bright_white",
    "plasma": "bright_magenta",
    "aurora": "bright_green",
    "electric": "bright_yellow",
    "midnight_purple": "bright_magenta",
    "coffee": "bright_yellow",
    "mint": "bright_green",
    "coral": "bright_red",
    "peach": "bright_red",
    "storm": "bright_cyan",
    "iceberg": "bright_blue",
    "twilight": "bright_magenta",
    "midnight_green": "bright_cyan",
    "ruby": "bright_red",
    "sapphire": "bright_blue",
    "emerald": "bright_green",
    "topaz": "bright_yellow",
    "onyx": "bright_white",
    "amethyst": "bright_magenta",
    "copper": "bright_yellow",
    "bronze": "bright_yellow",
    "platinum": "bright_white",
    "jade": "bright_green",
    "obsidian": "bright_white",
    "ivory": "bright_black",
}

def col(t, c):
    if c in C:
        return f"\033[{C[c]}m{t}\033[0m"
    return t

def sho(n):
    if n in T:
        return col(n, T[n])
    return n

D = {
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
        "defaults": DEFAULTS_DIR
    }
}

try:
    import psutil
    P = True
except ImportError:
    psutil = None
    P = False

class F:
    def __init__(self):
        self.mk()
        self.defs()
    
    def mk(self):
        for d in [PROJ_DIR, PLUG_DIR, DEFAULTS_DIR]:
            os.makedirs(d, exist_ok=True)
    
    def defs(self):
        a = os.path.join(DEFAULTS_DIR, "config.json")
        if not os.path.exists(a):
            with open(a, 'w') as f:
                json.dump(D, f, indent=2)
        
        b = os.path.join(DEFAULTS_DIR, "example.py")
        if not os.path.exists(b):
            with open(b, 'w') as f:
                f.write('''class Plugin:
    def __init__(self):
        self.name = "Hello World"
        self.version = "1.0"
        self.author = "user"
    
    def on_load(self):
        print(f"  [Hello World] Plugin loaded")
    
    def on_menu(self):
        print(f"  [Hello World] Type 'hello' to run")
    
    def run(self, project=None, data=None, color="default"):
        print(f"\\n=== Hello World ===\\n")
        print(f"Project: {project}")
        print(f"Color: {color}")
        print(f"Data: {data}")
        name = input("What's your name? ").strip()
        print(f"Hello {name}!")
    
    def on_suggest(self, msg):
        if "hello" in msg.lower():
            print(f"  [Hello World] Thanks for the suggestion!")
''')
    
    def ls(self, d, e=None):
        if e:
            return [f for f in glob.glob(f"{d}/*.{e}") if os.path.isfile(f)]
        return [f for f in glob.glob(f"{d}/*") if os.path.isfile(f)]
    
    def rj(self, p):
        try:
            with open(p, 'r') as f:
                return json.load(f)
        except:
            return {}
    
    def wj(self, p, d):
        try:
            with open(p, 'w') as f:
                json.dump(d, f, indent=2)
            return True
        except:
            return False
    
    def rf(self, p):
        try:
            with open(p, 'r') as f:
                return f.read()
        except:
            return ""
    
    def wf(self, p, c):
        try:
            with open(p, 'w') as f:
                f.write(c)
            return True
        except:
            return False

fm = F()

class X:
    def __init__(self):
        self.f = CONNECTIONS_FILE
        self.d = self.load()
        
    def load(self):
        return fm.rj(self.f)
    
    def save(self):
        fm.wj(self.f, self.d)
    
    def add(self, p, j, c=None):
        if p not in self.d:
            self.d[p] = {}
        self.d[p][j] = c or "default"
        self.save()
    
    def rem(self, p, j):
        if p in self.d and j in self.d[p]:
            del self.d[p][j]
            self.save()
    
    def getp(self, p):
        return self.d.get(p, {})
    
    def getj(self, j):
        r = []
        for p, js in self.d.items():
            if j in js:
                r.append((p, js[j]))
        return r

conn = X()

class Y:
    def __init__(self):
        self.c = ""
        self.t = 0
        
    def get(self):
        n = time.time()
        if n - self.t < 300 and self.c:
            return self.c
            
        try:
            r = urllib.request.Request(U6, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(r, timeout=3) as r:
                self.c = r.read().decode()
                self.t = n
                return self.c
        except:
            return self.c or "Failed to fetch update log"

up = Y()

class G:
    def __init__(self):
        self.c = []
        self.t = 0
        
    def url(self, n):
        return f"{U5}/{U4}/{n}"
    
    def api(self):
        return f"https://api.github.com/repos/{U1}/{U2}/contents/{U4}?ref={U3}"
    
    def fetch(self):
        n = time.time()
        if n - self.t < 300:
            return self.c
            
        try:
            u = self.api()
            r = urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(r, timeout=3) as r:
                d = json.loads(r.read().decode())
                self.c = []
                for i in d:
                    if i['name'].endswith('.py'):
                        self.c.append({
                            'n': i['name'],
                            'u': self.url(urllib.parse.quote(i['name']))
                        })
                self.t = n
                return self.c
        except:
            return self.c
    
    def ls(self):
        return self.fetch()

gh = G()

class Z:
    def __init__(self, f=CFG):
        self.f = f
        self.c = self.load()
        
    def load(self):
        d = fm.rj(os.path.join(DEFAULTS_DIR, "config.json")) or D
        if os.path.exists(self.f):
            try:
                u = fm.rj(self.f)
                for k, v in u.items():
                    d[k] = v
            except:
                pass
        return d
    
    def save(self):
        fm.wj(self.f, self.c)
    
    def proj(self):
        p = []
        
        for f in fm.ls(PROJ_DIR, 'py'):
            n = os.path.basename(f)
            p.append({'n': n, 'p': f, 'l': True})
        
        for g in gh.ls():
            if not any(x.get('n') == g['n'] for x in p):
                p.append({'n': g['n'], 'u': g['u']})
        
        return p
    
    def set(self, t):
        if t in T:
            self.c['settings']['theme'] = t
            self.save()

class Q:
    def __init__(self):
        self.p = {}
        self.f = {}
        self.load()
    
    def load(self):
        self.p = {}
        self.f = {}
        sys.path.insert(0, os.path.abspath(PLUG_DIR))
        
        for f in fm.ls(PLUG_DIR, 'py'):
            m = os.path.basename(f)[:-3]
            try:
                s = importlib.util.spec_from_file_location(m, f)
                mod = importlib.util.module_from_spec(s)
                s.loader.exec_module(mod)
                if hasattr(mod, 'Plugin'):
                    pl = mod.Plugin()
                    pl.path = f
                    pl.file = os.path.basename(f)
                    pl.name = getattr(pl, 'name', m)
                    pl.version = getattr(pl, 'version', '1.0')
                    pl.author = getattr(pl, 'author', 'unknown')
                    self.p[m] = pl
                    
                    df = os.path.join(DEFAULTS_DIR, f"{m}_data.json")
                    self.f[m] = fm.rj(df)
            except Exception as e:
                pass
    
    def save(self, n):
        if n in self.f:
            p = os.path.join(DEFAULTS_DIR, f"{n}_data.json")
            fm.wj(p, self.f[n])
    
    def run(self, n, j=None):
        if n in self.p:
            pl = self.p[n]
            if hasattr(pl, 'run'):
                try:
                    if j:
                        co = conn.getp(n)
                        c = co.get(j, "default")
                        print(col(f"\n[{n}] Running with {j} [{c}]\n", "bright_green"))
                        pl.run(j, self.f.get(n, {}), c)
                    else:
                        print(col(f"\n[{n}] Running\n", "bright_green"))
                        pl.run(None, self.f.get(n, {}), "default")
                    self.save(n)
                except Exception as e:
                    print(col(f"[-] Error: {e}", "bright_red"))
            else:
                print(col("[*] No run() method", "bright_yellow"))
        else:
            print(col(f"[-] Not found", "bright_red"))
    
    def edit(self, n):
        if n in self.p:
            p = self.p[n].path
            e = os.environ.get('EDITOR', 'nano')
            try:
                subprocess.run([e, p])
                self.load()
            except:
                print(col(f"[-] Failed to open {e}", "bright_red"))
        else:
            print(col(f"[-] Not found", "bright_red"))
    
    def view(self, n):
        if n in self.f:
            print(col(f"\nDATA for {n}:", "bright_cyan"))
            print(json.dumps(self.f[n], indent=2))
        else:
            print(col("[-] No data", "bright_yellow"))
    
    def editd(self, n):
        if n in self.f:
            print(col(f"\nEDIT DATA for {n} (key=value format, empty to stop):", "bright_cyan"))
            while True:
                kv = input("key=value: ").strip()
                if not kv:
                    break
                if '=' in kv:
                    k, v = kv.split('=', 1)
                    self.f[n][k] = v
                    self.save(n)
                    print(col(f"[+] Set {k}={v}", "bright_green"))
        else:
            self.f[n] = {}
            self.editd(n)
    
    def rem(self, n):
        if n in self.p:
            p = self.p[n].path
            try:
                os.remove(p)
                print(col(f"[+] Removed {n}", "bright_green"))
                self.load()
            except:
                print(col(f"[-] Failed to remove", "bright_red"))
        else:
            print(col(f"[-] Not found", "bright_red"))
    
    def inst(self, u):
        try:
            f = os.path.basename(u).split('?')[0]
            if not f.endswith('.py'):
                f = f + '.py'
            p = os.path.join(PROJ_DIR, f)
            
            print(col("[*] Downloading...", "bright_cyan"))
            
            if shutil.which("wget"):
                subprocess.run(["wget", "-O", p, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            elif shutil.which("curl"):
                subprocess.run(["curl", "-L", "-o", p, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                urllib.request.urlretrieve(u, p)
            
            if os.path.exists(p):
                print(col(f"[+] Downloaded: {f} to projects/", "bright_green"))
                return True
        except:
            print(col("[-] Failed", "bright_red"))
        return False
    
    def new(self):
        print(col("\nNEW PLUGIN", "bright_cyan"))
        n = input("name: ").strip()
        if not n:
            return
        if not n.endswith('.py'):
            n = n + '.py'
        
        t = '''class Plugin:
    def __init__(self):
        self.name = "''' + n[:-3] + '''"
        self.version = "1.0"
        self.author = "user"
    
    def on_load(self):
        print(f"  [''' + n[:-3] + '''] Plugin loaded")
    
    def on_menu(self):
        print(f"  [''' + n[:-3] + '''] Ready")
    
    def run(self, project=None, data=None, color="default"):
        print(f"\\n=== ''' + n[:-3] + ''' ===\\n")
        print(f"Project: {project}")
        print(f"Color: {color}")
        print(f"Data: {data}")
        print("Hello from plugin!")
'''
        
        p = os.path.join(PLUG_DIR, n)
        if fm.wf(p, t):
            print(col(f"[+] Created: {p}", "bright_green"))
            self.load()
            return p
        return None
    
    def ex(self):
        try:
            p = os.path.join(PLUG_DIR, "example.py")
            with open(p, 'w') as f:
                f.write('''class Plugin:
    def __init__(self):
        self.name = "Hello World"
        self.version = "1.0"
        self.author = "user"
    
    def on_load(self):
        print(f"  [Hello World] Plugin loaded")
    
    def on_menu(self):
        print(f"  [Hello World] Type 'hello' to run")
    
    def run(self, project=None, data=None, color="default"):
        print(f"\\n=== Hello World ===\\n")
        print(f"Project: {project}")
        print(f"Color: {color}")
        print(f"Data: {data}")
        name = input("What's your name? ").strip()
        print(f"Hello {name}!")
    
    def on_suggest(self, msg):
        if "hello" in msg.lower():
            print(f"  [Hello World] Thanks for the suggestion!")
''')
            print(col("[+] Example plugin created", "bright_green"))
            self.load()
            return True
        except:
            print(col("[-] Failed", "bright_red"))
            return False
    
    def instp(self, u):
        try:
            f = os.path.basename(u).split('?')[0]
            if not f.endswith('.py'):
                f = f + '.py'
            p = os.path.join(PLUG_DIR, f)
            
            print(col("[*] Installing plugin...", "bright_cyan"))
            
            if shutil.which("wget"):
                subprocess.run(["wget", "-O", p, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            elif shutil.which("curl"):
                subprocess.run(["curl", "-L", "-o", p, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                urllib.request.urlretrieve(u, p)
            
            if os.path.exists(p):
                print(col(f"[+] Installed: {f} to plugins/", "bright_green"))
                self.load()
                return True
        except:
            print(col("[-] Failed", "bright_red"))
        return False
    
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

def lip():
    try:
        return socket.gethostbyname(socket.gethostname())
    except:
        return "?"

def pip():
    try:
        with urllib.request.urlopen("https://api.ipify.org?format=json", timeout=2) as r:
            return json.loads(r.read().decode()).get("ip", "?")
    except:
        return "?"

def upt():
    if P:
        try:
            b = datetime.datetime.fromtimestamp(psutil.boot_time())
            d = datetime.datetime.now() - b
            return str(d).split(".")[0]
        except:
            pass
    return "?"

def ram():
    if P:
        try:
            m = psutil.virtual_memory()
            return f"{m.total / 1e9:.1f} GB"
        except:
            pass
    return "?"

def cpu():
    if P:
        try:
            return platform.processor() or "?"
        except:
            pass
    return "?"

def pan(c, p):
    clear()
    
    t = T.get(c.c['settings']['theme'], "bright_green")
    
    proj = c.proj()
    
    print(col(" ╭━━━━╮", t))
    print(col(" ┃╭╮╭╮┃", t))
    print(col(" ╰╯┃┃┣┻━┳━┳━━╮", t))
    print(col(" ╱╱┃┃┃┃━┫╭┫╭╮┃", t))
    print(col(" ╱╱┃┃┃┃━┫┃┃╭╮┃", t))
    print(col(" ╱╱╰╯╰━━┻╯╰╯╰╯   v7", t))
    print(col("────────────────────────────", t))
    print(col("", t))
    print(col("OS", t))
    print(col(f"  ├─ System  : {platform.system()} {platform.release()}", t))
    print(col(f"  ├─ Arch    : {platform.machine()}", t))
    print(col(f"  ├─ CPU     : {cpu()}", t))
    print(col(f"  ├─ RAM     : {ram()}", t))
    print(col(f"  ├─ Python  : {platform.python_version()}", t))
    print(col(f"  └─ Uptime  : {upt()}", t))
    print(col("", t))
    print(col(f"CWD        : {os.getcwd()}", t))
    print(col(f"Plugins    : {len(p.p)}", t))
    print(col(f"Theme      : {sho(c.c['settings']['theme'])}", t))
    print(col("+---------------------------", t))
    print(col("[--------]<FILES>[---------]", t))
    print(col(f"  Projects dir : {PROJ_DIR}/", t))
    print(col(f"  Plugins dir  : {PLUG_DIR}/", t))
    print(col(f"  Defaults dir : {DEFAULTS_DIR}/", t))
    print(col("[--------]<PLUGINS>[---------]", t))
    
    if p.p:
        for n, pl in p.p.items():
            if hasattr(pl, 'on_menu'):
                try:
                    pl.on_menu()
                except:
                    print(col(f"  [{n}] Active", t))
            else:
                print(col(f"  [{n}] Loaded", t))
    else:
        print(col("  No plugins loaded", t))
    
    print(col("+---------------------------", t))
    print(col("[PROJECTS]", t))
    if proj:
        for i,pr in enumerate(proj,1):
            if pr.get('l'):
                tx = "L"
            else:
                tx = "R"
            co = conn.getj(pr['n'])
            if co:
                cs = " [" + ",".join([c[0] for c in co]) + "]"
            else:
                cs = ""
            print(col(f"  {tx} {i:<2} | {pr['n']}{cs}", t))
    else:
        print(col("  No projects", t))
    print(col("|_________________", t))
    print(col("+-- P  | PLUGINS", t))
    print(col("+-- C  | CONFIG", t))
    print(col("+-- F  | FILES", t))
    print(col("+-- U  | UPDATE LOG", t))
    print(col("+-- 0  | EXIT", t))
    print(col("-------------", t))

def fmn(c, p):
    while True:
        clear()
        t = T.get(c.c['settings']['theme'], "bright_green")
        
        print(col("+--- FILE MANAGER", t))
        print(col("|", t))
        print(col("| DIRECTORIES:", t))
        print(col(f"|  1. {PROJ_DIR}/", t))
        print(col(f"|  2. {PLUG_DIR}/", t))
        print(col(f"|  3. {DEFAULTS_DIR}/", t))
        print(col("|", t))
        print(col("+-- 1-3 | LIST FILES", t))
        print(col("+-- 0   | BACK", t))
        print(col("-------------", t))
        
        ch = input("> ").strip()
        if ch == "0":
            break
        elif ch in ["1","2","3"]:
            ds = [PROJ_DIR, PLUG_DIR, DEFAULTS_DIR]
            d = ds[int(ch)-1]
            fs = fm.ls(d, 'py')
            clear()
            print(col(f"\nFILES in {d}/:", t))
            if fs:
                for i,f in enumerate(fs,1):
                    print(col(f"  {i}. {os.path.basename(f)}", t))
            else:
                print(col("  Empty directory", t))
            input("\nENTER...")

def upm(c):
    clear()
    t = T.get(c.c['settings']['theme'], "bright_green")
    
    print(col("Fetching latest updates...", "bright_cyan"))
    
    l = up.get()
    
    print(col(l, t))
    
    input(col("\nPress ENTER to return", t))

def ep():
    try:
        import pip
    except:
        subprocess.run([sys.executable, "-m", "ensurepip"])
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "--user", "pip", "setuptools", "wheel"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        pass

def gi(f):
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

def ck(m):
    return importlib.util.find_spec(m) is not None

def ins(ms):
    ep()
    miss = [m for m in ms if not ck(m)]
    if not miss:
        return
    
    print(col("[*] Installing required packages...", "bright_cyan"))
    
    for p in miss:
        try:
            ms = [
                [sys.executable, "-m", "pip", "install", "--user", p],
                [sys.executable, "-m", "pip", "install", p, "--break-system-packages"],
                ["pip3", "install", "--user", p],
                ["pip", "install", "--user", p]
            ]
            
            done = False
            for m in ms:
                try:
                    r = subprocess.run(m, capture_output=True, text=True)
                    if r.returncode == 0:
                        print(col(f"[+] Installed {p}", "bright_green"))
                        done = True
                        break
                except:
                    continue
            
            if not done:
                print(col(f"[-] Failed to install {p}", "bright_red"))
                print(col(f"[*] Try manually: pip install --user {p}", "bright_yellow"))
        except:
            pass

def dl(u):
    f = os.path.basename(u).split('?')[0]
    if os.path.exists(f):
        os.remove(f)
    
    print(col("[*] Fetching...", "bright_cyan"))
    
    try:
        if shutil.which("wget"):
            subprocess.run(["wget", "-O", f, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        elif shutil.which("curl"):
            subprocess.run(["curl", "-L", "-o", f, u], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            urllib.request.urlretrieve(u, f)
        return f
    except:
        return None

def ru(f):
    i = gi(f)
    if i:
        ins(i)
    subprocess.run([sys.executable, f])

def plm(p, proj, c):
    while True:
        clear()
        t = T.get(c.c['settings']['theme'], "bright_green")
        
        print(col("+--- PLUGIN MANAGER", t))
        print(col("|", t))
        print(col(f"| LOADED: {len(p.p)}", t))
        print(col("|", t))
        if p.p:
            for i,(n,pl) in enumerate(p.p.items(),1):
                v = getattr(pl, 'version', '1.0')
                a = getattr(pl, 'author', '?')
                co = conn.getp(n)
                if co:
                    cs = " [" + ",".join(co.keys()) + "]"
                else:
                    cs = ""
                print(col(f"|  {i}. {n} v{v} by {a}{cs}", t))
        else:
            print(col("|  No plugins", t))
        print(col("|", t))
        print(col("+-- I  | INSTALL PLUGIN (URL)", t))
        print(col("+-- D  | DOWNLOAD PROJECT (URL)", t))
        print(col("+-- R  | RUN PLUGIN", t))
        print(col("+-- C  | CONNECT TO PROJECT", t))
        print(col("+-- K  | DISCONNECT", t))
        print(col("+-- V  | VIEW DATA", t))
        print(col("+-- E  | EDIT DATA", t))
        print(col("+-- N  | EDIT CODE (nano)", t))
        print(col("+-- X  | DELETE", t))
        print(col("+-- W  | NEW", t))
        print(col("+-- M  | EXAMPLE", t))
        print(col("+-- L  | RELOAD", t))
        print(col("+-- 0  | BACK", t))
        print(col("-------------", t))
        
        ch = input("> ").strip().lower()
        if ch == "0":
            break
        elif ch == "i":
            u = input("plugin raw url: ").strip()
            if u:
                p.instp(u)
                input("\nENTER...")
        elif ch == "d":
            u = input("project url: ").strip()
            if u:
                p.inst(u)
                input("\nENTER...")
        elif ch == "r":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    idx = int(input("\nnumber: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        print(col("\nPROJECTS:", "bright_cyan"))
                        for i,pr in enumerate(proj,1):
                            print(col(f"  {i}. {pr['n']}", "bright_cyan"))
                        pidx = int(input("project number (0 for none): ")) - 1
                        if pidx >= 0 and pidx < len(proj):
                            j = proj[pidx]['n']
                        else:
                            j = None
                        print("")
                        p.run(n, j)
                    else:
                        print(col("[-] Invalid", "bright_red"))
                except:
                    print(col("[-] Invalid", "bright_red"))
            else:
                print(col("[-] No plugins", "bright_red"))
            input("\nENTER...")
        elif ch == "c":
            if p.p and proj:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    pidx = int(input("plugin number: ")) - 1
                    if 0 <= pidx < len(p.p):
                        n = list(p.p.keys())[pidx]
                        print(col("\nPROJECTS:", "bright_cyan"))
                        for i,pr in enumerate(proj,1):
                            print(col(f"  {i}. {pr['n']}", "bright_cyan"))
                        pjidx = int(input("project number: ")) - 1
                        if 0 <= pjidx < len(proj):
                            j = proj[pjidx]['n']
                            print(col("\nCOLORS:", "bright_cyan"))
                            cs = list(T.keys())
                            for i,co in enumerate(cs,1):
                                print(col(f"  {i}. {sho(co)}", "bright_cyan"))
                            cidx = int(input("color number (0 for default): ")) - 1
                            if cidx >= 0 and cidx < len(cs):
                                co = cs[cidx]
                            else:
                                co = "default"
                            conn.add(n, j, co)
                            print(col(f"[+] Connected {n} -> {j} [{co}]", "bright_green"))
                except:
                    pass
            else:
                print(col("[-] Need plugins and projects", "bright_red"))
            input("\nENTER...")
        elif ch == "k":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    co = conn.getp(n)
                    if co:
                        print(col(f"  {i}. {n} -> {list(co.keys())}", "bright_cyan"))
                try:
                    idx = int(input("plugin number: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        co = conn.getp(n)
                        if co:
                            print(col(f"\nCONNECTIONS for {n}:", "bright_cyan"))
                            cs = list(co.keys())
                            for i,j in enumerate(cs,1):
                                print(col(f"  {i}. {j}", "bright_cyan"))
                            cidx = int(input("connection number: ")) - 1
                            if 0 <= cidx < len(cs):
                                j = cs[cidx]
                                conn.rem(n, j)
                                print(col(f"[-] Disconnected {n} -> {j}", "bright_yellow"))
                except:
                    pass
            input("\nENTER...")
        elif ch == "v":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        p.view(n)
                except:
                    pass
            input("\nENTER...")
        elif ch == "e":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        p.editd(n)
                except:
                    pass
            input("\nENTER...")
        elif ch == "n":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        p.edit(n)
                except:
                    pass
            else:
                print(col("[-] No plugins", "bright_red"))
            input("\nENTER...")
        elif ch == "x":
            if p.p:
                print(col("\nPLUGINS:", "bright_cyan"))
                for i,(n,pl) in enumerate(p.p.items(),1):
                    print(col(f"  {i}. {n}", "bright_cyan"))
                try:
                    idx = int(input("number: ")) - 1
                    if 0 <= idx < len(p.p):
                        n = list(p.p.keys())[idx]
                        cf = input(f"remove {n}? (y/n): ")
                        if cf.lower() == 'y':
                            p.rem(n)
                    else:
                        print(col("[-] Invalid", "bright_red"))
                except:
                    print(col("[-] Invalid", "bright_red"))
            else:
                print(col("[-] No plugins", "bright_red"))
            input("\nENTER...")
        elif ch == "w":
            p.new()
            input("\nENTER...")
        elif ch == "m":
            if p.ex():
                print(col("[+] Example installed", "bright_green"))
            else:
                print(col("[-] Failed", "bright_red"))
            input("\nENTER...")
        elif ch == "l":
            p.load()
            print(col("[+] Reloaded", "bright_green"))
            input("\nENTER...")

def cfm(c):
    while True:
        clear()
        t = T.get(c.c['settings']['theme'], "bright_green")
        
        print(col("+--- CONFIG MANAGER", t))
        print(col("|", t))
        print(col(f"| Name     : {c.c.get('name', 'Tera')}", t))
        print(col(f"| Version  : {c.c.get('version', '7.0')}", t))
        print(col(f"| Theme    : {sho(c.c['settings']['theme'])}", t))
        print(col(f"| Debug    : {c.c['settings'].get('debug', False)}", t))
        print(col("|", t))
        print(col(f"| Available: {len(T)} themes", t))
        print(col("+-- T  | THEMES", t))
        print(col("+-- D  | TOGGLE DEBUG", t))
        print(col("+-- 0  | BACK", t))
        print(col("-------------", t))
        
        ch = input("> ").strip().lower()
        if ch == "0":
            break
        elif ch == "t":
            print(col("\nTHEMES:", "bright_cyan"))
            for t in sorted(T.keys()):
                print(f"  - {sho(t)}")
            t = input("\ntheme: ").strip().lower()
            if t in T:
                c.set(t)
        elif ch == "d":
            c.c['settings']['debug'] = not c.c['settings'].get('debug', False)
            c.save()

def main():
    c = Z()
    p = Q()
    p.hook('on_load')
    
    while True:
        proj = c.proj()
        pan(c, p)
        
        ch = input("> ").strip()
        
        if ch == "0":
            sys.exit(0)
        elif ch.lower() == "p":
            plm(p, proj, c)
        elif ch.lower() == "c":
            cfm(c)
        elif ch.lower() == "f":
            fmn(c, p)
        elif ch.lower() == "u":
            upm(c)
        elif ch.isdigit():
            i = int(ch) - 1
            if 0 <= i < len(proj):
                pr = proj[i]
                p.hook('on_run', pr['n'])
                if pr.get('l'):
                    ru(pr['p'])
                else:
                    f = dl(pr['u'])
                    if f and f.endswith('.py'):
                        shutil.move(f, os.path.join(PROJ_DIR, f))
                        ru(os.path.join(PROJ_DIR, f))
                input("\n[+] DONE. ENTER...")

if __name__ == "__main__":
    main()
