# Termux Setup Guide

This guide explains how to set up your development environment on Android using Termux and Arch Linux (proot-distro).

## Prerequisites

Your setup:
- **Device**: Samsung Galaxy S24 Ultra
- **Architecture**: aarch64 (ARM64)
- **OS**: Android with Termux
- **Environment**: Arch Linux via proot-distro

## Installation Steps

### 1. Install Termux

Install Termux from F-Droid (recommended) or GitHub releases:
- **F-Droid**: https://f-droid.org/packages/com.termux/
- **GitHub**: https://github.com/termux/termux-app/releases

⚠️ **Important**: Do NOT install from Google Play Store as it's outdated.

### 2. Update Termux Packages

```bash
pkg update && pkg upgrade
```

### 3. Install Required Termux Packages

Before installing Arch Linux, install these Termux packages:

```bash
pkg install \
  proot-distro \
  git \
  wget \
  curl \
  openssh
```

### 4. Install Arch Linux via proot-distro

```bash
# Install Arch Linux distribution
proot-distro install archlinux

# Login to Arch Linux
proot-distro login archlinux
```

### 5. Clone Your Dotfiles (Inside Arch Linux)

```bash
# Inside the Arch Linux proot environment
cd ~
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
```

### 6. Run the Installation Script

```bash
cd archlinux
bash install.sh
```

## Understanding the Setup

### What is proot-distro?

`proot-distro` allows you to run full Linux distributions inside Termux without root access. It uses `proot` to create a chroot-like environment.

### Key Differences from Native Linux

1. **No real kernel**: You're using the Android kernel
2. **No systemd**: proot-distro doesn't support systemd (services won't work the same way)
3. **Limited hardware access**: Some hardware features may not be available
4. **File system**: Uses Android's file system with proot overlay

### Architecture: aarch64

Your Samsung Galaxy S24 Ultra uses the ARM64 (aarch64) architecture. Most packages in Arch Linux ARM repositories support this architecture well.

## Tree-sitter Build Requirements

The tree-sitter compilation error you encountered (`#include asm/types.h not found`) is solved by installing:

1. **neovim** - The Neovim editor
2. **linux-api-headers** - Provides kernel API headers like `asm/types.h`
3. **tree-sitter** - The tree-sitter CLI tool
4. **base-devel** - Build tools (gcc, make, etc.)

These are now included in the `packages.sh` script.

## Common Issues and Solutions

### Issue 1: "asm/types.h not found" when building tree-sitter

**Cause**: Missing kernel headers required for compiling native C code.

**Solution**: Install `linux-api-headers` package (now included in packages.sh):
```bash
sudo pacman -S linux-api-headers
```

### Issue 2: Neovim not installed

**Cause**: Neovim was missing from the package list.

**Solution**: Now automatically installed via packages.sh:
```bash
sudo pacman -S neovim tree-sitter
```

### Issue 3: systemd services don't work

**Cause**: proot-distro doesn't support systemd.

**Solution**:
- For xremap: Start manually or use a different autostart method
- For other services: Use alternatives that don't require systemd

### Issue 4: Homebrew installation issues

**Cause**: Homebrew on ARM Linux (aarch64) has limited support.

**Solution**: Prefer pacman and AUR packages over Homebrew when possible. The install script handles this.

## Manual Service Start (if systemd doesn't work)

Since systemd might not work in proot-distro, you may need to start services manually:

### xremap (Keyboard Remapper)

If the systemd service fails, start xremap manually:

```bash
# In the background
nohup xremap ~/.config/xremap/config.yml > /tmp/xremap.log 2>&1 &
```

Add to your shell rc file (~/.zshrc or ~/.bashrc) to start on shell startup:

```bash
# Start xremap if not already running
if ! pgrep -x "xremap" > /dev/null; then
    nohup xremap ~/.config/xremap/config.yml > /tmp/xremap.log 2>&1 &
fi
```

## Storage Access

To access Android's shared storage from Termux:

```bash
termux-setup-storage
```

This creates symlinks in `~/storage/` pointing to various Android directories:
- `~/storage/shared` - Internal shared storage
- `~/storage/downloads` - Downloads folder
- `~/storage/dcim` - Camera folder

## Performance Tips

1. **Use Termux:API**: Install termux-api for additional Android features
2. **Battery optimization**: Disable battery optimization for Termux in Android settings
3. **Lock screen**: Use Termux wake lock to prevent sleep: `termux-wake-lock`
4. **Editor choice**: Consider using neovim built-in terminal instead of tmux for better performance

## Troubleshooting

### Check if you're in proot environment

```bash
uname -a
# Should show Linux kernel version
```

### Check architecture

```bash
uname -m
# Should show: aarch64
```

### Package installation fails

```bash
# Update package databases
sudo pacman -Syy

# Clear package cache if needed
sudo pacman -Scc
```

### Compilation errors persist

If tree-sitter still fails to compile after installing dependencies:

```bash
# Check if headers are accessible
ls /usr/include/asm/types.h

# If missing, reinstall linux-api-headers
sudo pacman -S --force linux-api-headers

# Check compiler
gcc --version

# Try compiling tree-sitter parsers manually
nvim --headless "+TSInstall c" +qa
```

## Resources

- **Termux Wiki**: https://wiki.termux.com/
- **proot-distro**: https://github.com/termux/proot-distro
- **Arch Linux ARM**: https://archlinuxarm.org/
- **Neovim**: https://neovim.io/

## Next Steps

After successful installation:

1. Restart Neovim and let LazyVim install plugins
2. Run `:checkhealth` in Neovim to verify setup
3. Tree-sitter parsers should now compile successfully
4. Customize your configuration as needed

## Notes for This Setup

- ✅ **Neovim**: Now installed automatically
- ✅ **Tree-sitter**: Compilation dependencies included
- ✅ **LazyVim**: Will work after Neovim installation
- ⚠️ **xremap**: May need manual start (systemd limitations)
- ⚠️ **Docker**: Limited support in proot-distro
- ⚠️ **GUI apps**: Not supported in proot-distro

