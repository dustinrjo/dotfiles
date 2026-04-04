# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#
# Make an alias for invoking commands you use constantly
# alias p='python'
export PATH="$HOME/.local/bin:$PATH"

# Make zellij the default code editor
alias code='zellij'
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
