# xremap Configuration for Arch Linux

This directory contains the xremap configuration that mirrors the Karabiner-Elements setup from macOS.

## What is xremap?

xremap is a key remapper for Linux that works at the input device level. It's the closest equivalent to Karabiner-Elements available for Linux, supporting complex key mappings, layers, and application-specific remapping.

## Installation

xremap is automatically installed via the `packages.sh` script from the AUR package `xremap-x11-bin`.

## Features Implemented

### 1. **Caps Lock → Ctrl/Esc**
- Hold Caps Lock: Acts as Left Ctrl
- Tap Caps Lock: Acts as Esc
- Timeout: 200ms

### 2. **Tab → Hyper/Tab**
- Hold Tab: Acts as Hyper key (Shift+Ctrl+Alt+Super)
- Tap Tab: Acts as Tab
- Timeout: 200ms

### 3. **Vim-style Navigation (Hyper + hjkl)**
- `Hyper + h` → Left Arrow
- `Hyper + j` → Down Arrow
- `Hyper + k` → Up Arrow
- `Hyper + l` → Right Arrow

### 4. **Desktop Management**
- `Hyper + m` → Mission Control (Ctrl+Up)
- `Hyper + ,` → Move left a space (Ctrl+Left)
- `Hyper + .` → Move right a space (Ctrl+Right)
- `Hyper + 1-9` → Switch to Desktop 1-9 (Ctrl+1-9)

### 5. **Application Launchers (Hyper + Shift + key)**
Since xremap doesn't support Karabiner-style sublayers with the same ease, we use `Hyper+Shift` combinations:
- `Hyper + Shift + j` → Brave Browser
- `Hyper + Shift + k` → Ghostty Terminal
- `Hyper + Shift + h` → Thunar File Manager
- `Hyper + Shift + t` → Microsoft Teams
- `Hyper + Shift + p` → Postman
- `Hyper + Shift + v` → VS Code
- `Hyper + Shift + b` → DBeaver
- `Hyper + Shift + m` → Thunderbird (Mail)

### 6. **Window Management (Hyper + w + key)**
Requires i3, sway, or similar tiling window manager:
- `Hyper + w + h/l` → Move window left/right
- `Hyper + w + j` → Center window
- `Hyper + w + Enter` → Toggle fullscreen
- `Hyper + w + =/-` → Resize window larger/smaller
- `Hyper + w + p` → Next window (Alt+Tab)

### 7. **Application Launcher (Hyper + f)**
- `Hyper + f` → Open rofi (Shortcat equivalent)

### 8. **German Umlauts**
- `Alt + a` → ä
- `Alt + Shift + a` → Ä
- `Alt + o` → ö
- `Alt + Shift + o` → Ö
- `Alt + u` → ü
- `Alt + Shift + u` → Ü

## Differences from Karabiner

### Sublayers
Karabiner supports complex sublayer logic where you can press `Hyper+e` and then another key. xremap's sublayer support is more limited, so we've adapted the configuration:

**Karabiner approach:**
1. Hold Tab (activates Hyper)
2. Press and hold `e` (activates sublayer_e)
3. Press `j` (opens Browser)

**xremap approach:**
1. Hold Tab + Shift (activates Hyper)
2. Press `j` (opens Browser)

### Window Management
Karabiner uses Rectangle app commands via shell scripts. On Linux, xremap calls i3/sway commands directly. If you're not using a tiling window manager, you'll need to:
1. Install a tiling WM (i3, sway, bspwm)
2. OR replace the window management commands with xdotool/wmctrl commands
3. OR remove the window management section

### Application-Specific Remapping
xremap supports application-specific remapping (not shown in this config), which Karabiner also supports. You can add `application:` blocks to enable/disable mappings per application.

## Usage

### Starting xremap

The systemd user service should auto-start after installation:
```bash
systemctl --user status xremap
```

### Manual start:
```bash
xremap ~/.config/xremap/config.yml
```

### Reload configuration after changes:
```bash
systemctl --user restart xremap
```

### View logs:
```bash
journalctl --user -u xremap -f
```

## Dependencies

Required packages:
- `xremap-x11-bin` (from AUR)
- `xdotool` (for German umlauts)
- `rofi` (for application launcher, can use `dmenu` instead)
- `i3-wm` or `sway` (for window management, optional)

## Customization

Edit `~/.config/xremap/config.yml` to customize the mappings. After editing, reload the service:

```bash
systemctl --user restart xremap
```

## Troubleshooting

### xremap not starting
Check permissions and logs:
```bash
journalctl --user -u xremap -n 50
```

### Keys not being remapped
1. Verify xremap is running: `systemctl --user status xremap`
2. Test with verbose mode: `xremap ~/.config/xremap/config.yml --watch`
3. Check if your keyboard is recognized: `xremap --device`

### Hyper key not working
The Hyper key is mapped as `Shift+Ctrl+Alt+Super`. Some applications might not recognize this combination. You can simplify to just `Super` if needed.

### German umlauts not working
Ensure `xdotool` is installed:
```bash
sudo pacman -S xdotool
```

## Alternative Tools

If xremap doesn't meet your needs, consider:
- **keyd**: Simpler, works at kernel level, no X11 dependency
- **kmonad**: More complex, QMK-inspired, very powerful
- **interception-tools**: Low-level, requires more setup

## Resources

- [xremap GitHub](https://github.com/k0kubun/xremap)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
- [Original Karabiner config](../../macos/karabiner/karabiner.json)

