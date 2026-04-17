#!/bin/bash

. scripts/utils.sh
. scripts/packages.sh

info "Dotfiles intallation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Apps"
    info "===================="

    install_packages
fi

printf "\n"
info "===================="
info "Terminal"
info "===================="

info "Adding .hushlogin file to suppress 'last login' message in terminal..."
touch ~/.hushlogin

printf "\n"
info "===================="
info "Symbolic Links"
info "===================="

chmod +x ./scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete
fi
./scripts/symlinks.sh

printf "\n"
info "===================="
info "xremap Service"
info "===================="

# Check if systemd is available (won't work in proot-distro/Termux)
if command -v systemctl &>/dev/null && systemctl --user status &>/dev/null 2>&1; then
    info "Enabling xremap systemd service..."
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable xremap.service 2>/dev/null || true
    systemctl --user start xremap.service 2>/dev/null || true

    if systemctl --user is-active --quiet xremap.service 2>/dev/null; then
        success "xremap service started successfully"
    else
        warning "xremap service failed to start. Check logs with: journalctl --user -u xremap"
    fi
else
    warning "systemd not available (common in Termux/proot environments)"
    info "To start xremap manually, run:"
    info "  nohup xremap ~/.config/xremap/config.yml > /tmp/xremap.log 2>&1 &"
    info ""
    info "Or add to your shell rc file (~/.zshrc or ~/.bashrc):"
    info "  if ! pgrep -x \"xremap\" > /dev/null; then"
    info "      nohup xremap ~/.config/xremap/config.yml > /tmp/xremap.log 2>&1 &"
    info "  fi"
fi

success "Dotfiles set up successfully."
