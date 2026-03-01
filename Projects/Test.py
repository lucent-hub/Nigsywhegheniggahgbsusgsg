import curses
import random
import time

logo = r"""
 ╭━━━━╮
 ┃╭╮╭╮┃
 ╰╯┃┃┣┻━┳━┳━━╮
 ╱╱┃┃┃┃━┫╭┫╭╮┃
 ╱╱┃┃┃┃━┫┃┃╭╮┃
 ╱╱╰╯╰━━┻╯╰╯╰╯"""

def kys(stdscr):
    curses.curs_set(0)  
    stdscr.nodelay(True)
    stdscr.timeout(50)

    sh, sw = stdscr.getmaxyx()
    columns = [0] * sw
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"

    start_time = time.time()
    Retard = False
    logo_lines = logo.splitlines()
    logo_h = len(logo_lines)
    logo_w = max(len(line) for line in logo_lines)
    logo_y = sh // 2 - logo_h // 2
    logo_x = sw // 2 - logo_w // 2

    while True:
        for i in range(sw):
            if random.random() > 0.9:
                columns[i] = 0
            char = random.choice(chars)
            stdscr.addstr(columns[i], i, char, curses.color_pair(1))
            columns[i] = (columns[i] + 1) % sh

        if not Retard and time.time() - start_time >= 2:
            for idx, line in enumerate(logo_lines):
                stdscr.addstr(logo_y + idx, logo_x, line, curses.color_pair(2))
            Retard = True

        
        if Retard:
            for idx, line in enumerate(logo_lines):
                stdscr.addstr(logo_y + idx, logo_x, line, curses.color_pair(2))
        
            exit_msg = "Press Y to exit"
            stdscr.addstr(logo_y + logo_h + 1, sw // 2 - len(exit_msg) // 2, exit_msg, curses.color_pair(2))

        stdscr.refresh()


        try:
            key = stdscr.getch()
            if key in [ord('Y'), ord('y')]:
                break
        except:
            pass

if __name__ == "__main__":
    curses.initscr()
    curses.start_color()
    curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)  
    curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)   
    curses.wrapper(kys)
