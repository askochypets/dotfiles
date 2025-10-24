#!/usr/bin/env bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

set -e

install_packages() {
  # ------------------------------------------------------------
  #  Ensure sudo
  # ------------------------------------------------------------
  if [[ "$EUID" -ne 0 && -z "$SUDO_USER" ]]; then
    if ! sudo -v &>/dev/null; then
      echo "This script requires sudo privileges."
      exit 1
    fi
  fi

  # ------------------------------------------------------------
  #  Ensure yay (AUR helper)
  # ------------------------------------------------------------
  if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    (cd "$tmpdir" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
  else
    info "yay is already installed."
  fi

  # ------------------------------------------------------------
  #  Packages from official Arch repositories
  # ------------------------------------------------------------
  PACMAN_PKGS=(
    readline
    aws-cli-v2
    cmake
    fzf
    gcc
    neofetch
    nodejs
    npm
    ranger
    ripgrep
    ruby
    tmux
    xclip
    zlib
    openssl
    poppler
    exa # 'eza' is AUR, exa is official
    zoxide
    lazygit
    zsh
    git
    curl
    wget
    unzip
    base-devel
    docker
  )

  info "Installing pacman packages..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  # ------------------------------------------------------------
  #  Packages from AUR (requires yay)
  # ------------------------------------------------------------
  if command -v yay &>/dev/null; then
    AUR_PKGS=(
      starship
      zsh-autosuggestions
      zsh-syntax-highlighting
      eza # modern 'exa' replacement (AUR)
      brave-bin
      dbeaver
      wezterm
      nerd-fonts-hack
      nerd-fonts-jetbrains-mono
      nerd-fonts-symbols-only
    )
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
  fi
}

info "✅ All requested packages installed successfully!"
