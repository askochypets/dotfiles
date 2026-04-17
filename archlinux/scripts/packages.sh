#!/usr/bin/env bash

set -euo pipefail

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"

# ------------------------------------------------------------
#  Error handling
# ------------------------------------------------------------
handle_error() {
  local step="$1"
  local line_number="$2"
  echo ""
  echo "❌ ERROR in install_packages at step: ${step}"
  echo "❌ Line number: ${line_number}"
  echo "❌ Please check the error message above for details"
  echo ""
  return 1
}

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
  local current_step=""

  # ------------------------------------------------------------
  #  Install base packages
  # ------------------------------------------------------------
  current_step="Installing base packages"
  info "${current_step}..."

  if ! sudo pacman -Syu --noconfirm; then
    handle_error "${current_step}" "${LINENO}"
    return 1
  fi

  if ! sudo pacman -S --needed --noconfirm base-devel git; then
    handle_error "${current_step}" "${LINENO}"
    return 1
  fi

  success "✅ Base packages installed"

  # ------------------------------------------------------------
  #  Install yay (AUR helper)
  # ------------------------------------------------------------
  if ! command -v yay &>/dev/null; then
    current_step="Installing yay (AUR helper)"
    info "${current_step}..."

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    if ! git clone https://aur.archlinux.org/yay.git "$tmpdir" 2>/dev/null; then
      handle_error "${current_step} - git clone failed" "${LINENO}"
      return 1
    fi

    # detect user to drop to
    TARGET_USER="${SUDO_USER:-$USER}"

    # build yay as normal user
    if ! sudo -u "$TARGET_USER" bash -c "cd '$tmpdir' && makepkg -si --noconfirm"; then
      handle_error "${current_step} - makepkg failed" "${LINENO}"
      return 1
    fi

    success "✅ yay installed successfully"
  else
    info "yay already installed, skipping..."
  fi

  # ------------------------------------------------------------
  #  Packages from official Arch repositories
  # ------------------------------------------------------------
  current_step="Installing pacman packages"
  info "${current_step}..."

  if ! sudo pacman -Syu --needed --noconfirm \
    readline aws-cli-v2 cmake fzf gcc nodejs npm ranger ripgrep \
    ruby tmux xclip zlib openssl poppler zoxide starship eza lazygit \
    zsh curl wget unzip nushell atuin neovim \
    zsh-autosuggestions zsh-syntax-highlighting \
    tree-sitter linux-api-headers; then
    handle_error "${current_step}" "${LINENO}"
    return 1
  fi

  success "✅ Pacman packages installed"

  # ------------------------------------------------------------
  #  Packages from AUR (requires yay)
  # ------------------------------------------------------------
  if command -v yay &>/dev/null; then
    current_step="Installing AUR packages"
    info "${current_step}..."

    TARGET_USER="${SUDO_USER:-$USER}"

    if ! sudo -u "$TARGET_USER" bash -c "yay -S --needed --noconfirm --nocleanmenu --nodiffmenu \
      carapace-bin fnm-bin nerd-fonts-hack nerd-fonts-jetbrains-mono nerd-fonts-symbols-only"; then
      warning "⚠️  Some AUR packages failed to install, continuing..."
      info "You can install them manually later with: yay -S <package-name>"
    else
      success "✅ AUR packages installed"
    fi
  else
    warning "⚠️  yay not available, skipping AUR packages"
  fi

  success "✅ All requested packages installed successfully!"
}
