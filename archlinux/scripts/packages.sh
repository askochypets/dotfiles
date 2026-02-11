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
    runuser -u "$TARGET_USER" -- bash -c "cd '$tmpdir' && makepkg -si --noconfirm"

    info "✅ yay installed successfully."
  else
    info "yay already installed."
  fi

  # ------------------------------------------------------------
  #  Packages from official Arch repositories
  # ------------------------------------------------------------
  info "Installing pacman packages..."
  sudo pacman -Syu --needed --noconfirm \
    readline aws-cli-v2 cmake fzf gcc neofetch nodejs npm ranger ripgrep ruby tmux xclip zlib openssl poppler zoxide lazygit zsh curl wget unzip docker

  # ------------------------------------------------------------
  #  Packages from AUR (requires yay)
  # ------------------------------------------------------------
  if command -v yay &>/dev/null; then
    TARGET_USER="${SUDO_USER:-$USER}"
    runuser -u "$TARGET_USER" -- bash -c "yay -S --needed --noconfirm \
      starship zsh-autosuggestions zsh-syntax-highlighting eza \
      brave-bin dbeaver wezterm nerd-fonts-hack nerd-fonts-jetbrains-mono nerd-fonts-symbols-only"
  fi

  success "✅ All requested packages installed successfully!"
}
