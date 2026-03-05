import sys
import time
import threading

running = True

def loader():
    frames = ["/", "|", "\\", "|"]
    i = 0
    while running:
        sys.stdout.write("\r" + frames[i % len(frames)] + "   Press X to exit")
        sys.stdout.flush()
        i += 1
        time.sleep(0.15)

def wait_exit():
    global running
    while True:
        key = input().lower()
        if key == "x":
            running = False
            break

t1 = threading.Thread(target=loader)
t2 = threading.Thread(target=wait_exit)

t1.start()
t2.start()

t1.join()
print("\nExited.")
