#!/bin/sh

set -e

REPO="agentosroza-dev/agentos-font"
RAW_URL="https://raw.githubusercontent.com/$REPO/main"

FONT_DIR="${FONT_DIR:-"$HOME/.local/share/fonts/agentos"}"

detect_platform() {
  case "$(uname -s)" in
    Linux)   PLATFORM="linux" ;;
    Darwin)  PLATFORM="macos" ;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM="windows" ;;
    *)       PLATFORM="unknown" ;;
  esac
}

set_font_dir() {
  case "$PLATFORM" in
    linux)
      FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/agentos"
      ;;
    macos)
      FONT_DIR="$HOME/Library/Fonts/agentos"
      ;;
    windows)
      FONT_DIR="$LOCALAPPDATA/Microsoft/Windows/Fonts/agentos"
      ;;
  esac
}

download_fonts() {
  echo "Fetching font list..."
  FONTS=$(curl -sSL "https://api.github.com/repos/$REPO/contents/fonts" \
    | grep '"name"' | grep '\.ttf' | cut -d'"' -f4)

  if [ -z "$FONTS" ]; then
    echo "Failed to fetch font list. Using fallback method..."

    TEMP_DIR=$(mktemp -d)
    echo "Downloading repository archive..."
    curl -sSL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" \
      -o "$TEMP_DIR/repo.tar.gz"

    mkdir -p "$TEMP_DIR/extracted"
    tar xzf "$TEMP_DIR/repo.tar.gz" -C "$TEMP_DIR/extracted"

    mkdir -p "$FONT_DIR"
    find "$TEMP_DIR/extracted" -name '*.ttf' -exec cp -v {} "$FONT_DIR/" \;

    rm -rf "$TEMP_DIR"
    return
  fi

  mkdir -p "$FONT_DIR"

  echo "$FONTS" | while IFS= read -r font; do
    echo "Downloading $font..."
    curl -sSL "$RAW_URL/fonts/$font" -o "$FONT_DIR/$font"
  done
}

install_fonts() {
  detect_platform

  if [ "$PLATFORM" = "unknown" ]; then
    echo "Unsupported platform. Falling back to default font directory."
  fi

  set_font_dir
  echo "Installing fonts to: $FONT_DIR"
  echo ""

  download_fonts

  echo ""
  echo "Updating font cache..."
  if command -v fc-cache > /dev/null 2>&1; then
    fc-cache -fv "$FONT_DIR"
  fi

  if command -v updatemime > /dev/null 2>&1; then
    updatemime 2>/dev/null || true
  fi

  echo ""
  echo "Fonts installed successfully!"
}

uninstall_fonts() {
  detect_platform
  set_font_dir

  if [ -d "$FONT_DIR" ]; then
    echo "Removing fonts from: $FONT_DIR"
    rm -rf "$FONT_DIR"

    if command -v fc-cache > /dev/null 2>&1; then
      echo "Updating font cache..."
      fc-cache -fv
    fi

    echo "Fonts uninstalled."
  else
    echo "No agentos fonts found at $FONT_DIR"
  fi
}

usage() {
  cat <<EOF
Usage: curl -sSL https://raw.githubusercontent.com/$REPO/main/install.sh | sh [-- [install|uninstall]]

Commands:
  install   (default) Install fonts
  uninstall            Remove fonts

Environment:
  FONT_DIR  Custom font installation directory (default: autodetected)
EOF
}

case "${1:-install}" in
  install)
    install_fonts
    ;;
  uninstall)
    uninstall_fonts
    ;;
  --help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
