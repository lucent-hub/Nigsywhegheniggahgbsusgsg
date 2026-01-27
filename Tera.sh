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
  "1|Webhook Sender|https://url.com/menu.py"
  "2|Example Project|https://project.com/script.sh"
   "3|test|https://url.com/test.py"
)

detect_pkg_manager() {
  if command -v apt > /dev/null 2>&1; then
    echo "apt"
  elif command -v pacman > /dev/null 2>&1; then
    echo "pacman"
  elif command -v dnf > /dev/null 2>&1; then
    echo "dnf"
  elif command -v yum > /dev/null 2>&1; then
    echo "yum"
  elif command -v zypper > /dev/null 2>&1; then
    echo "zypper"
  elif command -v pkg > /dev/null 2>&1; then
    echo "pkg"
  else
    echo "none"
  fi
}

install_wget() {
  if command -v wget > /dev/null 2>&1; then
    return
  fi

  PKG_MANAGER=$(detect_pkg_manager)
  SUDO=""
  if command -v sudo > /dev/null 2>&1; then
    SUDO="sudo"
  fi

  case $PKG_MANAGER in
    apt)
      $SUDO apt update
      $SUDO apt install -y wget
      ;;
    pacman)
      $SUDO pacman -Sy --noconfirm wget
      ;;
    dnf)
      $SUDO dnf install -y wget
      ;;
    yum)
      $SUDO yum install -y wget
      ;;
    zypper)
      $SUDO zypper install -y wget
      ;;
    pkg)
      pkg install -y wget
      ;;
    *)
      echo "No supported package manager found."
      exit 1
      ;;
  esac
}

menu() {
  clear
  logo

  echo "Projects:"
  for p in "${projects[@]}"; do
    IFS="|" read -r key name url <<< "$p"
    echo "[$key] $name"
  done
  echo "[0] Exit"
  echo

  read -p "Choose project: " choice

  if [[ "$choice" == "0" ]]; then
    exit 0
  fi

  for p in "${projects[@]}"; do
    IFS="|" read -r key name url <<< "$p"
    if [[ "$choice" == "$key" ]]; then
      download_project "$name" "$url"
      return
    fi
  done

  echo "Invalid choice."
  sleep 1
  menu
}

download_project() {
  local name="$1"
  local url="$2"

  install_wget

  echo "Downloading $name..."
  wget "$url"

  if [[ $? -eq 0 ]]; then
    echo "Download completed."
  else
    echo "Download failed."
    read -p "Press Enter to return to menu..."
    menu
    return
  fi

  read -p "Wanna start $name? (y/n): " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    run_download "$url"
  else
    menu
  fi
}

run_download() {
  local url="$1"
  local file_name=$(basename "$url")

  case "$file_name" in
    *.sh)
      bash "$file_name"
      ;;
    *.py)
      python3 "$file_name"
      ;;
    *)
      echo "Can't auto-run this file type."
      echo "You can run it manually."
      ;;
  esac

  read -p "Press Enter to return to menu..."
  menu
}

menu
