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
- **Shell tools**: zsh, nushell, fzf, ripgrep, ranger, starship, eza
- **ZSH plugins**: zsh-autosuggestions, zsh-syntax-highlighting
- **Version control**: git, lazygit
- **Multiplexer**: tmux
- **Cloud tools**: aws-cli-v2
- **System libraries**: readline, zlib, openssl, poppler, linux-api-headers
- **Utilities**: curl, wget, unzip, xclip, zoxide, atuin
- **Languages**: nodejs, npm, ruby

### AUR Packages (via yay)

- **Fonts**: Nerd Fonts (Hack, JetBrains Mono, Symbols Only)
- **Shell completion**: carapace-bin
- **Node version manager**: fnm-bin

## Configuration

Configurations are managed via GNU Stow and symlinked from:
- `core/` - Shared configurations (neovim, tmux, zsh, etc.)
- `archlinux/` - Arch-specific configurations (systemd services)

## Special Features

### Keyboard Remapping

**⚠️ NOT AVAILABLE in Termux/proot environments**

System-level keyboard remapping tools (keyd, xremap, kmonad) require direct hardware access to `/dev/input/` devices, which is not available in Termux/proot containers.

**For Termux users**: Use Android-level remapping solutions instead:
- **External Keyboard Helper Pro** (recommended) - Full system-wide remapping
- **Android Settings** → Physical Keyboard - Basic remapping
- **Termux keyboard configuration** - Terminal-only key mappings

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
- **Keyboard remapping**: System-level tools require direct hardware access not available in proot
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

### Installation Failed

Check the installation log for detailed error messages:
```bash
cat archlinux/install.log
```

The install script provides detailed step tracking and will show exactly where the installation failed.

## File Structure

```
archlinux/
├── README.md                      # This file
├── install.sh                     # Main installation script
├── .stowrc                        # Stow configuration
└── scripts/
    ├── packages.sh                # Package installation
    ├── symlinks.sh                # Symlink creation via stow
    └── utils.sh                   # Utility functions
```

## Manual Installation Steps

If you prefer to run steps individually:

```bash
# 1. Install packages
bash scripts/packages.sh

# 2. Create symlinks
bash scripts/symlinks.sh
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

### Termux on Android

Special considerations:
- Use F-Droid Termux (Play Store version is outdated)
- Grant storage permissions: `termux-setup-storage`
- Disable battery optimization for Termux
- Consider using `termux-wake-lock` to prevent sleep

## Related Documentation

- **Termux Setup**: `../termux/README.md`
- **Core configs**: `../core/`

## Changes from macOS Setup

Key differences from the macOS setup:
1. Uses `pacman` instead of Homebrew for core packages
2. No keyboard remapping in Termux/proot (use Android-level solutions)
3. Systemd services instead of launchd (when available)
4. Linux-specific paths and configurations

## Contributing

When adding new packages:
1. Prefer `pacman` for core system packages
2. Use AUR for Linux-specific or unavailable packages
3. Test on both native Linux and Termux/proot if possible

## Support

For issues specific to:
- **Termux/Android**: See `../termux/README.md`
- **Neovim/LazyVim**: Check `:checkhealth` in Neovim

