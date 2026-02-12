import sys
import time
import random

def killmyself(text):
    for char in text:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(random.uniform(0.05, 0.2) if char.isalnum() else random.uniform(0.2, 0.5))
        if random.random() < 0.1 and char.isalnum():
            sys.stdout.write(random.choice(["~nya", " >///<", " hehe~"]))
            sys.stdout.flush()
            time.sleep(random.uniform(0.2, 0.5))

killmyself("Ay sem- sem- Sempai! Go to the other project~ >///<")
