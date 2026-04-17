# Tree-sitter Compilation Fix for Termux/Arch Linux

## Problem

When running LazyVim inside Arch Linux (proot-distro) on Termux (Android/aarch64), tree-sitter parser compilation fails with:

```
#include asm/types.h not found
```

## Root Causes

### 1. Missing Neovim
Neovim was not included in the package installation list, so LazyVim couldn't run.

### 2. Missing Kernel Headers
The `linux-api-headers` package, which provides userspace kernel API headers including `asm/types.h`, was not explicitly installed.

### 3. Missing Tree-sitter CLI
The tree-sitter CLI tool wasn't installed for debugging and manual parser compilation.

## Solution

The following packages have been added to `archlinux/scripts/packages.sh`:

```bash
sudo pacman -Syu --needed --noconfirm \
  neovim \
  tree-sitter \
  linux-api-headers
```

### Package Details

1. **neovim** - The Neovim editor itself
   - Required to run LazyVim
   - Includes tree-sitter integration

2. **tree-sitter** - Tree-sitter CLI tool
   - Allows manual parser compilation
   - Useful for debugging
   - Provides shared libraries

3. **linux-api-headers** - Linux kernel API headers
   - Provides `asm/types.h` and other kernel headers
   - Required for compiling native C code
   - Userspace headers (not for kernel modules)

## Why This Works

### Understanding the Build Process

Tree-sitter parsers are written in C and must be compiled for your system:

1. **Parser source** → Downloaded by nvim-treesitter
2. **C compiler** → Uses gcc from base-devel
3. **Kernel headers** → Includes `asm/types.h` (from linux-api-headers)
4. **Build tools** → Uses cmake, make (from base-devel)
5. **Compiled parser** → Loaded by Neovim

### Architecture Considerations

On **aarch64** (ARM64) devices like Samsung Galaxy S24 Ultra:
- All packages are available for ARM64
- Arch Linux ARM repositories are well-maintained
- No special configuration needed
- Compilation happens natively on the device

### proot-distro Specifics

When running Arch Linux inside Termux via proot-distro:
- Uses the Android kernel (not a Linux kernel)
- `linux-api-headers` provides userspace-compatible headers
- No actual kernel access needed for tree-sitter compilation
- Build process works identically to native Arch Linux

## Testing the Fix

After running the updated install script:

```bash
# 1. Verify packages are installed
pacman -Q neovim tree-sitter linux-api-headers

# 2. Check if asm/types.h is available
ls -l /usr/include/asm/types.h

# 3. Open Neovim
nvim

# 4. Check LazyVim health
:checkhealth

# 5. Manually install a tree-sitter parser (if needed)
:TSInstall c

# 6. Verify tree-sitter works
:TSInstallInfo
```

## Expected Output

### Successful Installation

```
neovim 0.10.x-x
tree-sitter 0.x.x-x
linux-api-headers 6.x.x-x
```

### Successful tree-sitter Compilation

```vim
:TSInstall c
# Should show:
[nvim-treesitter] [0/1] Downloading tree-sitter-c...
[nvim-treesitter] [0/1] Compiling tree-sitter-c...
[nvim-treesitter] [1/1] ✓ c
```

## Additional Dependencies

These were already in the script but are crucial:

- **base-devel** - Provides gcc, make, binutils
- **gcc** - C compiler (included in base-devel)
- **cmake** - Build system generator
- **nodejs**, **npm** - Some parsers need Node.js

## Troubleshooting

### If compilation still fails:

```bash
# 1. Verify all build dependencies
pacman -Q base-devel gcc cmake nodejs npm

# 2. Reinstall linux-api-headers
sudo pacman -S --force linux-api-headers

# 3. Check compiler works
gcc --version
echo '#include <asm/types.h>' | gcc -x c -E - > /dev/null && echo "Headers OK"

# 4. Try compiling manually
cd ~/.local/share/nvim/lazy/nvim-treesitter
nvim --headless "+TSInstall c" +qa

# 5. Check for errors
nvim --headless "+checkhealth" +qa
```

### If Neovim is missing:

```bash
sudo pacman -S neovim
```

### Verify tree-sitter binary:

```bash
tree-sitter --version
which tree-sitter
```

## Platform Compatibility

This fix works on:
- ✅ Native Arch Linux (x86_64)
- ✅ Native Arch Linux (aarch64)
- ✅ Arch Linux ARM on Raspberry Pi
- ✅ Arch Linux in Termux (proot-distro) on Android
- ✅ Samsung Galaxy S24 Ultra (confirmed)

## Related Files

- `archlinux/scripts/packages.sh` - Updated with new packages
- `archlinux/README.md` - Documentation updated
- `termux/README.md` - Termux-specific guide created
- `core/nvim/` - LazyVim configuration

## References

- **linux-api-headers**: https://archlinux.org/packages/core/any/linux-api-headers/
- **neovim**: https://archlinux.org/packages/extra/x86_64/neovim/
- **tree-sitter**: https://archlinux.org/packages/extra/x86_64/tree-sitter/
- **nvim-treesitter**: https://github.com/nvim-treesitter/nvim-treesitter

## Summary

The tree-sitter compilation error is now **fixed** by ensuring three critical packages are installed:
1. `neovim` - The editor
2. `tree-sitter` - The CLI tool
3. `linux-api-headers` - The kernel headers

All tree-sitter parsers configured in LazyVim should now compile successfully on your Samsung Galaxy S24 Ultra running Arch Linux in Termux.

