#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
OS="$(uname -s)"

stow_package() { echo "Stowing $1..."; stow --target="$HOME" --restow "$1"; }

if [ "$OS" = "Darwin" ]; then
  stow_package "nvim_omarchy"
  stow_package "zsh_mac"
  stow_package "homebrew_mac"
elif [ "$OS" = "Linux" ]; then
  stow_package "nvim_omarchy"
  stow_package "bash_omarchy"
  stow_package "hypr_omarchy"
fi
