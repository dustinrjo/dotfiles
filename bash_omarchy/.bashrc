# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells.
# Omarchy 4 moved this out of ~/.local/share/omarchy; keep this line first.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
# Omarchy 3.x has no env-bootstrap and lives in ~/.local/share/omarchy; its
# desktop session usually exports OMARCHY_PATH, but a TTY or SSH login may not.
: "${OMARCHY_PATH:=$HOME/.local/share/omarchy}"
[[ -r $OMARCHY_PATH/default/bash/rc ]] && source "$OMARCHY_PATH/default/bash/rc"

# ---------------------------------------------------------------------------
# Personal exports, aliases, and functions below.
# Everything here is guarded so this file also works on a machine that doesn't
# have the tool installed yet.
# ---------------------------------------------------------------------------

# Omarchy 4's env-bootstrap already puts ~/.local/bin on PATH; this keeps the
# file working on non-Omarchy machines without duplicating the entry.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# cargo
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# pyenv
if [ -d "$HOME/.pyenv" ] || command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  command -v pyenv >/dev/null 2>&1 || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Make zellij the default code editor
if command -v zellij >/dev/null 2>&1; then
  alias code='zellij'
fi

alias la='ls -a'
alias gs='git status'

gall() {
  if [ -z "$1" ]; then
    echo "Usage: gall 'your commit message'"
  else
    git add . && git commit -m "$1"
  fi
}

shopt -s autocd

# Omarchy's first-word completion only lists commands; add folders back for autocd
complete -I -A command -A directory -X 'omarchy-*'

# Grok CLI (keep the installer's markers so a reinstall doesn't append a second copy)
# >>> grok installer >>>
[ -d "$HOME/.grok/bin" ] && export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<
