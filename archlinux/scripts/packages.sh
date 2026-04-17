#!/usr/bin/env bash

set -euo pipefail

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

# ------------------------------------------------------------
#  Ensure sudo privileges early
# ------------------------------------------------------------
if [[ "$EUID" -ne 0 && -z "${SUDO_USER:-}" ]]; then
  if ! sudo -v &>/dev/null; then
    echo "❌ This script requires sudo privileges."
    exit 1
  fi
fi

install_packages() {
  info "Installing base packages..."
  sudo pacman -Syu --noconfirm
  sudo pacman -S --needed --noconfirm base-devel git

  # ------------------------------------------------------------
  #  Install yay (AUR helper)
  # ------------------------------------------------------------
  if ! command -v yay &>/dev/null; then
    info "Installing yay..."

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$tmpdir"

    # detect user to drop to
    TARGET_USER="${SUDO_USER:-$USER}"

    # build yay as normal user
    sudo -u "$TARGET_USER" bash -c "cd '$tmpdir' && makepkg -si --noconfirm"

    info "✅ yay installed successfully."
  else
    info "yay already installed."
  fi

  # ------------------------------------------------------------
  #  Packages from official Arch repositories
  # ------------------------------------------------------------
  info "Installing pacman packages..."
  sudo pacman -Syu --needed --noconfirm \
    readline aws-cli-v2 cmake fzf gcc nodejs npm ranger ripgrep ruby tmux xclip zlib openssl poppler zoxide lazygit zsh curl wget unzip nushell \
    neovim tree-sitter linux-api-headers

  # ------------------------------------------------------------
  #  Packages from AUR (requires yay)
  # ------------------------------------------------------------
  if command -v yay &>/dev/null; then
    TARGET_USER="${SUDO_USER:-$USER}"
    sudo -u "$TARGET_USER" bash -c "yay -S --needed --noconfirm \
      nerd-fonts-hack nerd-fonts-jetbrains-mono nerd-fonts-symbols-only xremap-x11-bin"
  fi

  # ------------------------------------------------------------
  #  Install Homebrew
  # ------------------------------------------------------------
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."

    TARGET_USER="${SUDO_USER:-$USER}"

    # Install Homebrew as normal user
    sudo -u "$TARGET_USER" bash -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

    # Add Homebrew to PATH for this script
    if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
      export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    fi

    info "✅ Homebrew installed successfully."
  else
    info "Homebrew already installed."
  fi

  # ------------------------------------------------------------
  #  Install Homebrew packages
  # ------------------------------------------------------------
  if command -v brew &>/dev/null; then
    info "Installing Homebrew packages..."
    TARGET_USER="${SUDO_USER:-$USER}"

    sudo -u "$TARGET_USER" bash -c 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install carapace zoxide fnm starship zsh-autosuggestions zsh-syntax-highlighting eza'

    info "✅ Homebrew packages installed successfully."
  fi

  success "✅ All requested packages installed successfully!"
}
