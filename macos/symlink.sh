#!/bin/bash

set -e

# Stow zsh files directly to home
stow -t ~ zsh/.nvmenv
stow -t ~ zsh/.nvmrc

# Stow vimrc to home
stow -t ~ vim/.vimrc

# Stow all remaining packages to ~/.config
stow .
