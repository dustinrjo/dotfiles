# Enable Powerlevel10k instant prompt. Must stay at the very top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # Theme handled by powerlevel10k (sourced below)

# Update behavior
# zstyle ':omz:update' mode disabled
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' mode reminder

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Editor
export EDITOR=nvim

# VS Code CLI (single entry, deduplicated)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# pyenv
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# zsh plugins (installed via brew)
[[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases
alias la='ls -la'
alias gs='git status'
gall() { git add -A && git commit -m "$*"; }

# macOS-specific
alias code='open -a "Visual Studio Code"'

# zoxide (smart cd)
eval "$(zoxide init zsh --cmd cd)"

# Powerlevel10k (installed via brew)
[[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]] && \
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Machine-local secrets and overrides (never committed)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# p10k config — run `p10k configure` to regenerate
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
