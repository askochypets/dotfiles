# env.nu
#
# Installed by:
# version = "0.108.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

use std/util "path add"
path add /usr/local
path add /usr/local/bin
path add /usr/local/sbin
path add /usr/bin
path add /usr/sbin
path add /bin
path add /sbin
path add /Users/andriiskochypets

mkdir ~/.local/share/atuin/
atuin init nu | save -f ~/.local/share/atuin/init.nu

$env.STARSHIP_CONFIG = '/Users/andriiskochypets/.config/starship/starship.toml'
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

zoxide init nushell | save -f ~/.zoxide.nu