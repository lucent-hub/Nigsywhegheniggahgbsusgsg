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
  "1|Webhook Sender|https://url.com/menu.py|python3 python3-pip pip:requests"
  "2|Example Project|https://project.com/script.sh|curl jq"
  "3|Test Tool|https://url.com/test.py|python3"
)

detect_pkg_manager() {
  if command -v apt >/dev/null 2>&1; then echo apt
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v yum >/dev/null 2>&1; then echo yum
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  elif command -v pkg >/dev/null 2>&1; then echo pkg
  else echo none
  fi
}

install_wget() {
  command -v wget >/dev/null 2>&1 && return
  pm=$(detect_pkg_manager)
  sudo_cmd=""
  command -v sudo >/dev/null 2>&1 && sudo_cmd="sudo"

  case $pm in
    apt) $sudo_cmd apt update && $sudo_cmd apt install -y wget ;;
    pacman) $sudo_cmd pacman -Sy --noconfirm wget ;;
    dnf) $sudo_cmd dnf install -y wget ;;
    yum) $sudo_cmd yum install -y wget ;;
    zypper) $sudo_cmd zypper install -y wget ;;
    pkg) pkg install -y wget ;;
    *) echo "No supported package manager"; exit 1 ;;
  esac
}

install_deps() {
  deps="$1"
  [[ -z "$deps" ]] && return

  pip_deps=""
  if [[ "$deps" == *pip:* ]]; then
    pip_deps="${deps#*pip:}"
    deps="${deps%%pip:*}"
  fi

  pm=$(detect_pkg_manager)
  sudo_cmd=""
  command -v sudo >/dev/null 2>&1 && sudo_cmd="sudo"

  case $pm in
    apt) [[ -n "$deps" ]] && $sudo_cmd apt install -y $deps ;;
    pacman) [[ -n "$deps" ]] && $sudo_cmd pacman -S --noconfirm $deps ;;
    dnf) [[ -n "$deps" ]] && $sudo_cmd dnf install -y $deps ;;
    yum) [[ -n "$deps" ]] && $sudo_cmd yum install -y $deps ;;
    zypper) [[ -n "$deps" ]] && $sudo_cmd zypper install -y $deps ;;
    pkg) [[ -n "$deps" ]] && pkg install -y $deps ;;
  esac

  [[ -n "$pip_deps" ]] && pip3 install $pip_deps
}

menu() {
  clear
  logo

  for p in "${projects[@]}"; do
    IFS="|" read -r key name url deps <<< "$p"
    echo "[$key] $name"
  done
  echo "[0] Exit"
  echo

  read -p "Choose project: " choice
  [[ "$choice" == "0" ]] && exit 0

  for p in "${projects[@]}"; do
    IFS="|" read -r key name url deps <<< "$p"
    if [[ "$choice" == "$key" ]]; then
      download_project "$name" "$url" "$deps"
      return
    fi
  done

  sleep 1
  menu
}

download_project() {
  name="$1"
  url="$2"
  deps="$3"

  install_wget
  install_deps "$deps"

  wget -q --show-progress "$url"
  [[ $? -ne 0 ]] && menu

  read -p "Start $name? (y/n): " ans
  [[ "$ans" =~ ^[Yy]$ ]] && run_download "$url"
  menu
}

run_download() {
  file="$(basename "$1")"

  case "$file" in
    *.sh) bash "$file" ;;
    *.py) python3 "$file" ;;
  esac

  read -p "Press Enter..."
}

menu
