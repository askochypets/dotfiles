#!/bin/bash

set -e

if [[ "$1" == "--delete" ]]; then
  # Remove stow relations
  stow -D -d ../core -t ~ home
  stow -D -d ../core -t ~/.config .
  stow -D .
else
  # Stow zshrc & zshenv & vimrc files directly to home
  stow -d ../core -t ~ home
  # Stow core packages to ~/.config
  stow -d ../core -t ~/.config .
  # Stow archlinux specific packages to ~/.config
  stow .
fi
