#!/bin/bash

set -euo pipefail

# ------------------------------------------------------------
#  Error handling and logging
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/install.log"

# Track current step for error reporting
CURRENT_STEP=""

error_handler() {
  local line_number=$1
  echo ""
  echo "❌ ERROR: Installation failed at step: ${CURRENT_STEP}"
  echo "❌ Line number: ${line_number}"
  echo "❌ Check log file: ${LOG_FILE}"
  echo ""
  exit 1
}

trap 'error_handler ${LINENO}' ERR

log() {
  local message="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${message}" | tee -a "${LOG_FILE}"
}

step() {
  local step_name="$1"
  CURRENT_STEP="${step_name}"
  echo ""
  echo "===================================================="
  echo "STEP: ${step_name}"
  echo "===================================================="
  log "Starting: ${step_name}"
}

step_success() {
  log "✅ Completed: ${CURRENT_STEP}"
  echo "✅ ${CURRENT_STEP} completed successfully"
}

# ------------------------------------------------------------
#  Source utilities
# ------------------------------------------------------------
CURRENT_STEP="Loading utility scripts"
. scripts/utils.sh
. scripts/packages.sh

# ------------------------------------------------------------
#  Start installation
# ------------------------------------------------------------
log "===================================================="
log "Dotfiles installation started"
log "===================================================="

info "Dotfiles installation initialized..."
echo ""

# Default to 'y' if user just presses Enter
read -r -p "Install apps? [Y/n] " install_apps
install_apps=${install_apps:-y}

read -r -p "Overwrite existing dotfiles? [Y/n] " overwrite_dotfiles
overwrite_dotfiles=${overwrite_dotfiles:-y}

# ------------------------------------------------------------
#  Install packages
# ------------------------------------------------------------
if [[ "$install_apps" =~ ^[Yy]$ ]]; then
  step "Installing packages"

  if install_packages; then
    step_success
  else
    error_handler ${LINENO}
  fi
fi

# ------------------------------------------------------------
#  Terminal configuration
# ------------------------------------------------------------
step "Configuring terminal"

info "Adding .hushlogin file to suppress 'last login' message in terminal..."
if touch ~/.hushlogin; then
  step_success
else
  error_handler ${LINENO}
fi

# ------------------------------------------------------------
#  Create symbolic links
# ------------------------------------------------------------
step "Creating symbolic links"

if chmod +x ./scripts/symlinks.sh; then
  log "Made symlinks.sh executable"
else
  error_handler ${LINENO}
fi

if [[ "$overwrite_dotfiles" =~ ^[Yy]$ ]]; then
  warning "Deleting existing dotfiles..."
  if ./scripts/symlinks.sh --delete; then
    log "Deleted existing dotfiles"
  else
    error_handler ${LINENO}
  fi
fi

if ./scripts/symlinks.sh; then
  step_success
else
  error_handler ${LINENO}
fi

# ------------------------------------------------------------
#  Installation complete
# ------------------------------------------------------------
echo ""
echo "===================================================="
success "✅ Dotfiles set up successfully!"
echo "===================================================="
log "Installation completed successfully"
log "===================================================="
echo ""
echo "📝 Installation log: ${LOG_FILE}"
echo ""
