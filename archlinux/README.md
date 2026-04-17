# Arch Linux Setup

Automated setup scripts for Arch Linux development environment.

## Supported Platforms

- **Native Arch Linux** (x86_64, aarch64)
- **Arch Linux in Termux** (via proot-distro on Android/aarch64)

## Quick Start

```bash
cd archlinux
bash install.sh
```

## What Gets Installed

### System Packages (via pacman)

Core development tools and utilities:
- **Build tools**: base-devel, gcc, cmake
- **Editors**: neovim, tree-sitter
- **Shell tools**: zsh, nushell, fzf, ripgrep, ranger
- **Version control**: git, lazygit
- **Multiplexer**: tmux
- **Cloud tools**: aws-cli-v2
- **System libraries**: readline, zlib, openssl, poppler, linux-api-headers
- **Utilities**: curl, wget, unzip, xclip, zoxide

### AUR Packages (via yay)

- **Fonts**: Nerd Fonts (Hack, JetBrains Mono, Symbols Only)
- **Keyboard remapper**: xremap-x11-bin

### Homebrew Packages

Cross-platform tools:
- **Shell**: carapace, zoxide, starship
- **ZSH plugins**: zsh-autosuggestions, zsh-syntax-highlighting
- **Node version manager**: fnm
- **File tools**: eza

## Configuration

Configurations are managed via GNU Stow and symlinked from:
- `core/` - Shared configurations (neovim, tmux, zsh, etc.)
- `archlinux/` - Arch-specific configurations (xremap, systemd services)

## Special Features

### Keyboard Remapping (xremap)

xremap provides Karabiner-Elements-like functionality:
- Caps Lock → Ctrl/Esc (hold/tap)
- Tab → Hyper key (hold/tap)
- Vim-style navigation
- Application launchers
- Desktop/workspace switching

See `archlinux/xremap/README.md` for details.

### LazyVim / Neovim

Full LazyVim setup with tree-sitter support for syntax highlighting and code analysis.

**Tree-sitter Compilation Requirements:**
- `neovim` - The editor
- `tree-sitter` - Tree-sitter CLI
- `linux-api-headers` - Kernel headers (provides `asm/types.h`)
- `base-devel` - Build tools (gcc, make, etc.)
- `nodejs`, `npm` - Required for some parsers

All dependencies are automatically installed by `packages.sh`.

## Termux Support (Android)

This setup fully supports Arch Linux running in Termux via proot-distro on ARM64 devices.

### Termux Prerequisites

See `../termux/README.md` for detailed setup instructions.

Quick summary:
1. Install Termux from F-Droid (not Play Store)
2. Install proot-distro: `pkg install proot-distro git`
3. Install Arch Linux: `proot-distro install archlinux`
4. Login: `proot-distro login archlinux`
5. Run this install script

### Known Limitations in Termux/proot

- **systemd services**: Don't work in proot environment
  - xremap must be started manually or via shell rc file
- **Docker**: Limited functionality
- **GUI applications**: Not supported in proot-distro

## Troubleshooting

### Tree-sitter Compilation Fails

**Error**: `#include asm/types.h not found`

**Solution**: This is fixed by installing `linux-api-headers`:
```bash
sudo pacman -S linux-api-headers neovim tree-sitter
```

These packages are now automatically installed by the script.

### xremap Not Starting

**Native Linux with systemd:**
```bash
systemctl --user status xremap
journalctl --user -u xremap -f
```

**Termux/proot (no systemd):**
Start manually:
```bash
nohup xremap ~/.config/xremap/config.yml > /tmp/xremap.log 2>&1 &
```

### Homebrew Issues

If Homebrew installation fails (common on aarch64):
```bash
# Use native packages instead
sudo pacman -S starship eza zoxide
```

## File Structure

```
archlinux/
├── README.md                 # This file
├── install.sh               # Main installation script
├── .stowrc                  # Stow configuration
├── scripts/
│   ├── packages.sh          # Package installation
│   ├── symlinks.sh          # Symlink creation via stow
│   └── utils.sh             # Utility functions
├── xremap/
│   ├── config.yml           # Keyboard remapping config
│   └── README.md            # xremap documentation
└── systemd/
    └── user/
        └── xremap.service   # xremap systemd service
```

## Manual Installation Steps

If you prefer to run steps individually:

```bash
# 1. Install packages
bash scripts/packages.sh

# 2. Create symlinks
bash scripts/symlinks.sh

# 3. Enable xremap (if systemd available)
systemctl --user daemon-reload
systemctl --user enable --now xremap.service
```

## Environment Variables

The install script respects:
- `SUDO_USER` - Used to determine the target user for installations
- `HOME` - Home directory for configurations

## Platform-Specific Notes

### aarch64 (ARM64)

All packages work on ARM64 architecture:
- Native Arch Linux ARM repositories
- AUR packages compiled for aarch64
- Homebrew Linux ARM support

### Termux on Android

Special considerations:
- Use F-Droid Termux (Play Store version is outdated)
- Grant storage permissions: `termux-setup-storage`
- Disable battery optimization for Termux
- Consider using `termux-wake-lock` to prevent sleep

## Related Documentation

- **Termux Setup**: `../termux/README.md`
- **xremap**: `xremap/README.md`
- **Core configs**: `../core/`

## Changes from macOS Setup

Key differences from the macOS setup:
1. Uses `pacman` instead of Homebrew for core packages
2. Uses `xremap` instead of Karabiner-Elements
3. Systemd services instead of launchd (when available)
4. Linux-specific paths and configurations

## Contributing

When adding new packages:
1. Prefer `pacman` for core system packages
2. Use AUR for Linux-specific or unavailable packages
3. Use Homebrew only for cross-platform CLI tools
4. Test on both native Linux and Termux/proot if possible

## Support

For issues specific to:
- **Termux/Android**: See `../termux/README.md`
- **Keyboard remapping**: See `xremap/README.md`
- **Neovim/LazyVim**: Check `:checkhealth` in Neovim

