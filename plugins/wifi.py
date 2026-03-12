#!/usr/bin/env python3

import sys
import subprocess
import time
import os

def install(pkg):
    try:
        __import__(pkg)
    except:
        subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])

install("psutil")

import psutil

class Plugin:

    def __init__(self):
        self.name = "wifi"
        self.running = False
        self.interface = None
        self.upload = 0
        self.download = 0
        self.signal = 0
        self.rx_last = 0
        self.tx_last = 0
        self.graph_down = []
        self.graph_up = []
        self.graph_signal = []

    def A(self):
        for iface in psutil.net_if_stats().keys():
            name = iface.lower()
            if "wl" in name or "wifi" in name or "wlan" in name:
                return iface
        return list(psutil.net_if_stats().keys())[0]

    def B(self):
        try:
            if sys.platform.startswith("linux"):
                out = subprocess.getoutput("iwconfig")
                for line in out.split("\n"):
                    if "Signal level" in line:
                        level = int(line.split("Signal level=")[1].split()[0])
                        return min(100, max(0, (level + 100) * 2))
            if sys.platform == "darwin":
                out = subprocess.getoutput("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I")
                for line in out.split("\n"):
                    if "agrCtlRSSI" in line:
                        rssi = int(line.split(":")[1].strip())
                        return min(100, max(0, (rssi + 100) * 2))
        except:
            pass
        return self.signal

    def C(self):
        io = psutil.net_io_counters(pernic=True)
        if self.interface not in io:
            return
        rx = io[self.interface].bytes_recv
        tx = io[self.interface].bytes_sent
        self.download = (rx - self.rx_last) / 1024 / 1024
        self.upload = (tx - self.tx_last) / 1024 / 1024
        self.rx_last = rx
        self.tx_last = tx

    def D(self, arr, val, maxlen=30):
        arr.append(val)
        if len(arr) > maxlen:
            arr.pop(0)
        bars = ""
        for v in arr:
            h = int(min(8, v * 4))
            bars += " ▁▂▃▄▅▆▇█"[h]
        return bars

    def E(self):
        down_graph = self.D(self.graph_down, self.download)
        up_graph = self.D(self.graph_up, self.upload)
        sig_graph = self.D(self.graph_signal, self.signal / 100)
        return down_graph, up_graph, sig_graph

    def F(self, down_graph, up_graph, sig_graph):
        os.system("clear" if os.name != "nt" else "cls")
        print("WIFI RADAR\n")
        print(f"Interface : {self.interface}\n")
        print(f"v Download : {self.download:.2f} MB/s")
        print(down_graph + "\n")
        print(f"▲ Upload   : {self.upload:.2f} MB/s")
        print(up_graph + "\n")
        print(f"▼ Signal   : {self.signal}%")
        print(sig_graph)

    def G(self):
        while self.running:
            self.C()
            self.signal = self.B()
            d,u,s = self.E()
            self.F(d,u,s)
            time.sleep(1)

    def run(self):
        self.interface = self.A()
        io = psutil.net_io_counters(pernic=True)
        if self.interface not in io:
            print("No interface detected")
            return
        self.rx_last = io[self.interface].bytes_recv
        self.tx_last = io[self.interface].bytes_sent
        self.running = True
        try:
            self.G()
        except KeyboardInterrupt:
            self.running = False
            print("\nStopped")

if __name__ == "__main__":
    Plugin().run()
