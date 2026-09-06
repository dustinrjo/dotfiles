#!/usr/bin/env bash
# Stow this repo's packages for the current platform.
# Safe to re-run; use --adopt only on a machine whose existing configs you are
# willing to lose (see README, or use bootstrap.sh).
set -euo pipefail
cd "$(dirname "$0")"

ADOPT=0
for arg in "$@"; do
  case "$arg" in
    --adopt) ADOPT=1 ;;
    -h | --help)
      echo "Usage: $0 [--adopt]"
      echo "  --adopt  Absorb existing files in \$HOME into the repo instead of"
      echo "           refusing to overwrite them. Leaves the repo dirty; review"
      echo "           with 'git diff' and either commit or 'git checkout -- .'."
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

OS="$(uname -s)"

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is not installed." >&2
  if [ "$OS" = "Linux" ] && [ -r /etc/os-release ] && grep -q '^ID=omarchy' /etc/os-release; then
    echo "On Omarchy, sync the package databases through Omarchy first, then install:" >&2
    echo "  omarchy update" >&2
    echo "  sudo pacman -S stow" >&2
    echo "Or run ./bootstrap.sh, which does all of it." >&2
  else
    echo "Install it with your package manager (pacman -S stow / apt install stow / brew install stow)." >&2
  fi
  exit 1
fi

stow_args=(--target="$HOME" --restow)
[ "$ADOPT" -eq 1 ] && stow_args=(--target="$HOME" --adopt --restow)

stow_package() {
  echo "Stowing $1..."
  stow "${stow_args[@]}" "$1"
}

if [ "$OS" = "Darwin" ]; then
  stow_package "nvim_omarchy"
  stow_package "zsh_mac"
  stow_package "homebrew_mac"
  stow_package "claude"
elif [ "$OS" = "Linux" ]; then
  stow_package "nvim_omarchy"
  stow_package "bash_omarchy"
  stow_package "claude"
  stow_package "hypr_omarchy"
else
  echo "Unsupported platform: $OS" >&2
  exit 1
fi

if [ "$ADOPT" -eq 1 ] && ! git diff --quiet; then
  echo
  echo "--adopt pulled existing files from \$HOME into the repo. Review them:"
  echo "  git -C \"$PWD\" diff"
  echo "Then keep the repo's versions with 'git checkout -- .', or commit to keep \$HOME's."
fi
