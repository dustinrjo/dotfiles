#!/usr/bin/env bash
#
# Fresh-machine bootstrap for these dotfiles.
#
# Intended for a machine you have just installed and whose current shell and
# editor config you do not care about: step 4 DISCARDS the existing ~/.bashrc
# and ~/.config/nvim contents in favour of this repo's versions.
#
# Run directly from a clean Omarchy install:
#   bash <(curl -fsSL https://raw.githubusercontent.com/dustinrjo/dotfiles/master/bootstrap.sh)
#
# ...or from an existing clone:
#   ~/dotfiles/bootstrap.sh
#
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/dustinrjo/dotfiles.git}"
# An explicitly exported DOTFILES_DIR wins over the running-from-a-clone
# detection below; otherwise the script would silently operate on its own
# checkout instead of the directory it was told to use.
DOTFILES_DIR_SET=0
[ -n "${DOTFILES_DIR:-}" ] && DOTFILES_DIR_SET=1
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SKIP_UPDATE=0
SKIP_NVIM=0
SKIP_PLUGINS=0
ASSUME_YES=0

usage() {
  cat <<'USAGE'
Usage: bootstrap.sh [options]

  --skip-update   Don't run the system update (assumes stow is installable already)
  --skip-nvim     Don't run the initial 'Lazy! sync' plugin install
  --skip-plugins  Don't install the Omarchy shell plugins
  -y, --yes       Don't prompt before discarding existing config
  -h, --help      Show this help

Environment:
  DOTFILES_REPO   Repo to clone   (default: https://github.com/dustinrjo/dotfiles.git)
  DOTFILES_DIR    Clone location  (default: ~/dotfiles)
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-update) SKIP_UPDATE=1 ;;
    --skip-nvim) SKIP_NVIM=1 ;;
    --skip-plugins) SKIP_PLUGINS=1 ;;
    -y | --yes) ASSUME_YES=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RESET=$'\033[0m'
else
  BOLD='' DIM='' RED='' GREEN='' YELLOW='' RESET=''
fi

step() { echo; echo "${BOLD}==> $*${RESET}"; }
info() { echo "    $*"; }
warn() { echo "${YELLOW}    warning: $*${RESET}" >&2; }
die() {
  echo "${RED}error: $*${RESET}" >&2
  exit 1
}

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ -t 0 ] || die "not running interactively; re-run with --yes to accept the above"
  local reply
  read -r -p "    $1 [y/N] " reply
  [[ $reply =~ ^[Yy]$ ]]
}

# --------------------------------------------------------------------------
step "Checking prerequisites"

[ "$(id -u)" -ne 0 ] || die "run this as your normal user, not root"
command -v git >/dev/null 2>&1 || die "git is required but not installed"

OS="$(uname -s)"
FLAVOUR="unknown"
case "$OS" in
  Darwin) FLAVOUR="macos" ;;
  Linux)
    if [ -r /etc/os-release ]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      case "${ID:-}" in
        omarchy) FLAVOUR="omarchy" ;;
        arch) FLAVOUR="arch" ;;
        debian | ubuntu) FLAVOUR="debian" ;;
        *) [[ ${ID_LIKE:-} == *arch* ]] && FLAVOUR="arch" ;;
      esac
    fi
    ;;
esac
[ "$FLAVOUR" = "unknown" ] && die "unsupported platform: $OS"
info "platform: ${GREEN}${FLAVOUR}${RESET}"
[ "$FLAVOUR" = "omarchy" ] && info "omarchy:  $(omarchy-version 2>/dev/null || echo unknown)"

# --------------------------------------------------------------------------
step "Updating the system"

if [ "$SKIP_UPDATE" -eq 1 ]; then
  info "${DIM}skipped (--skip-update)${RESET}"
else
  case "$FLAVOUR" in
    omarchy)
      # Never 'pacman -Syu' here: Omarchy's 00-omarchy-update-guard hook aborts
      # any pacman command carrying both -S and -u and points at this instead.
      # It is also what populates /var/lib/pacman/sync on a clean install.
      info "running 'omarchy update' (will prompt for sudo)"
      if [ "$ASSUME_YES" -eq 1 ]; then omarchy update -y; else omarchy update; fi
      ;;
    arch) sudo pacman -Syu --noconfirm ;;
    debian)
      sudo apt-get update
      sudo apt-get upgrade -y
      ;;
    macos) command -v brew >/dev/null 2>&1 && brew update || warn "homebrew not installed; skipping update" ;;
  esac
fi

# --------------------------------------------------------------------------
step "Installing GNU stow"

if command -v stow >/dev/null 2>&1; then
  info "already installed ($(stow --version | head -1))"
else
  case "$FLAVOUR" in
    omarchy | arch)
      if [ ! -e /var/lib/pacman/sync/core.db ]; then
        die "pacman databases are not populated; re-run without --skip-update"
      fi
      # Plain -S carries no -u, so the Omarchy update guard does not apply.
      sudo pacman -S --needed --noconfirm stow
      ;;
    debian) sudo apt-get install -y stow ;;
    macos)
      command -v brew >/dev/null 2>&1 || die "install homebrew first: https://brew.sh"
      brew install stow
      ;;
  esac
  command -v stow >/dev/null 2>&1 || die "stow still not on PATH after install"
  info "installed $(stow --version | head -1)"
fi

# --------------------------------------------------------------------------
step "Obtaining the dotfiles repo"

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if [ "$DOTFILES_DIR_SET" -eq 0 ] && [ -n "$SELF_DIR" ] && [ -d "$SELF_DIR/.git" ] && [ -d "$SELF_DIR/nvim_omarchy" ]; then
  DOTFILES_DIR="$SELF_DIR"
  info "running from an existing clone: $DOTFILES_DIR"
elif [ -e "$DOTFILES_DIR" ]; then
  [ -d "$DOTFILES_DIR/.git" ] || die "$DOTFILES_DIR exists but is not a git repo; move it aside"
  info "using existing clone: $DOTFILES_DIR"
  info "${DIM}not pulling — update it yourself if you want the latest${RESET}"
else
  info "cloning $REPO_URL -> $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
git diff --quiet && git diff --cached --quiet ||
  die "$DOTFILES_DIR has uncommitted changes; commit or stash them first"

# --------------------------------------------------------------------------
step "Linking config into \$HOME"

warn "this replaces the existing shell and editor config in \$HOME with this repo's."
info "${DIM}a copy of whatever is there now is kept in the repo's working tree until${RESET}"
info "${DIM}the reset below, so 'git diff' shows exactly what is being discarded.${RESET}"
confirm "Continue?" || die "aborted"

./install.sh --adopt

if git diff --quiet; then
  info "${GREEN}nothing to discard — \$HOME already matched the repo${RESET}"
else
  echo
  info "the following existing files were absorbed and will now be discarded:"
  git --no-pager diff --stat | sed 's/^/    /'
  git checkout -- .
  info "${GREEN}reset to the committed versions${RESET}"
fi

# --------------------------------------------------------------------------
step "Installing Neovim plugins"

if [ "$SKIP_NVIM" -eq 1 ]; then
  info "${DIM}skipped (--skip-nvim)${RESET}"
elif ! command -v nvim >/dev/null 2>&1; then
  warn "nvim not installed; skipping plugin sync"
else
  info "running 'Lazy! sync' (first run downloads plugins)"
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -1
  # Lazy writes lazy-lock.json through the stow symlink, into the repo.
  if ! git diff --quiet -- nvim_omarchy/.config/nvim/lazy-lock.json; then
    info "${YELLOW}lazy-lock.json changed; commit it to pin these versions:${RESET}"
    info "  git -C \"$DOTFILES_DIR\" commit -am 'update lazy-lock'"
  fi
fi

# --------------------------------------------------------------------------
step "Installing Omarchy shell plugins"

# id -> repo. `omarchy plugin add --enable` clones into
# ~/.config/omarchy/plugins/<id> and switches to it; enablement is recorded by
# the shell, so nothing here needs stowing.
OMARCHY_PLUGINS=(
  "oedo.lock=https://github.com/dustinrjo/omarchy-lock-oedo.git"
)

if [ "$SKIP_PLUGINS" -eq 1 ]; then
  info "${DIM}skipped (--skip-plugins)${RESET}"
elif [ "$FLAVOUR" != "omarchy" ]; then
  info "${DIM}not Omarchy; skipping${RESET}"
else
  for entry in "${OMARCHY_PLUGINS[@]}"; do
    plugin_id="${entry%%=*}"
    plugin_url="${entry#*=}"
    if [ -e "$HOME/.config/omarchy/plugins/$plugin_id" ]; then
      info "$plugin_id already installed"
      continue
    fi
    # A cosmetic plugin must never fail the whole bootstrap.
    if omarchy plugin add "$plugin_url" --enable --yes; then
      info "${GREEN}installed $plugin_id${RESET}"
    else
      warn "could not install $plugin_id; continuing without it"
    fi
  done
fi

# --------------------------------------------------------------------------
step "Done"

info "repo:  $DOTFILES_DIR"
info "shell: restart it, or run 'exec bash', to pick up the new ~/.bashrc"
if [ "$FLAVOUR" = "omarchy" ]; then
  info "theme: set it with 'omarchy theme set <name>' — it is deliberately not tracked here"
fi
echo
