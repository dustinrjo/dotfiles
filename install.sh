#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
OS="$(uname -s)"

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is not installed." >&2
  if [ "$OS" = "Linux" ] && [ -r /etc/os-release ] && grep -q '^ID=omarchy' /etc/os-release; then
    echo "On Omarchy, sync the package databases through Omarchy first, then install:" >&2
    echo "  omarchy update" >&2
    echo "  sudo pacman -S stow" >&2
  else
    echo "Install it with your package manager (pacman -S stow / apt install stow / brew install stow)." >&2
  fi
  exit 1
fi

stow_package() { echo "Stowing $1..."; stow --target="$HOME" --restow "$1"; }

if [ "$OS" = "Darwin" ]; then
  stow_package "nvim_omarchy"
  stow_package "zsh_mac"
  stow_package "homebrew_mac"
elif [ "$OS" = "Linux" ]; then
  stow_package "nvim_omarchy"
  stow_package "bash_omarchy"
fi
