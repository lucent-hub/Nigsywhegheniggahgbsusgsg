#!/bin/bash

logo() {
echo "╭━━━━╮"
echo "┃╭╮╭╮┃"
echo "╰╯┃┃┣┻━┳━┳━━╮"
echo "╱╱┃┃┃┃━┫╭┫╭╮┃"
echo "╱╱┃┃┃┃━┫┃┃╭╮┃"
echo "╱╱╰╯╰━━┻╯╰╯╰╯ V0.1"
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
}

projects=(
  "1|license lookup|fevber-die-plz.vercel.app/Projects/Car.sh|"
)

detect_pkg_manager() {
  if command -v pkg >/dev/null 2>&1; then echo pkg
  elif command -v apt >/dev/null 2>&1; then echo apt
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v yum >/dev/null 2>&1; then echo yum
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  else echo none
  fi
}

install_wget() {
  command -v wget >/dev/null 2>&1 && return
  pm=$(detect_pkg_manager)

  echo "Checking required packages..."
  echo "Installing: wget"

  case $pm in
    pkg) pkg install -y wget ;;
    apt) apt install -y wget ;;
    pacman) pacman -S --noconfirm wget ;;
    dnf) dnf install -y wget ;;
    yum) yum install -y wget ;;
    zypper) zypper install -y wget ;;
    *) echo "Package manager not supported"; exit 1 ;;
  esac
}

install_deps() {
  deps="$1"
  [[ -z "$deps" ]] && return

  echo "Checking required packages..."
  echo "Installing: $deps"

  pip_deps=""
  if [[ "$deps" == *pip:* ]]; then
    pip_deps="${deps#*pip:}"
    deps="${deps%%pip:*}"
  fi

  pm=$(detect_pkg_manager)

  case $pm in
    pkg) [[ -n "$deps" ]] && pkg install -y $deps ;;
    apt) [[ -n "$deps" ]] && apt install -y $deps ;;
    pacman) [[ -n "$deps" ]] && pacman -S --noconfirm $deps ;;
    dnf) [[ -n "$deps" ]] && dnf install -y $deps ;;
    yum) [[ -n "$deps" ]] && yum install -y $deps ;;
    zypper) [[ -n "$deps" ]] && zypper install -y $deps ;;
  esac

  [[ -n "$pip_deps" ]] && pip3 install $pip_deps
}

menu() {
  clear
  logo

  for p in "${projects[@]}"; do
    IFS="|" read -r k n u d <<< "$p"
    echo "[$k] $n"
  done
  echo "[0] Exit"
  echo

  read -p "Choose project: " c
  [[ "$c" == "0" ]] && exit 0

  for p in "${projects[@]}"; do
    IFS="|" read -r k n u d <<< "$p"
    [[ "$c" == "$k" ]] && download_project "$n" "$u" "$d"
  done
}

download_project() {
  name="$1"
  url="$2"
  deps="$3"

  install_wget
  install_deps "$deps"

  echo "Downloading $name..."
  wget -q --show-progress "$url" || menu

  read -p "Start $name? (y/n): " a
  [[ "$a" =~ ^[Yy]$ ]] && run_download "$(basename "$url")"
  menu
}

run_download() {
  file="$1"

  if head -n 1 "$file" | grep -qi "<!DOCTYPE html>"; then
    echo "Downloaded file is HTML, not executable."
    echo "Check the URL — it may be a webpage."
    read -p "Press Enter..."
    return
  fi

  case "$file" in
    *.sh) bash "$file" ;;
    *.py) python3 "$file" ;;
    *) echo "Unsupported file type." ;;
  esac

  read -p "Press Enter..."
}

menu
