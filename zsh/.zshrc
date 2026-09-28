# ── Oh My Zsh ────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# ── Environment ──────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── PATH additions ───────────────────────────────────────────────────────
# Neovim
[ -d /opt/nvim-linux-x86_64/bin ] && export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# nvm (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Rust (rustup, installed with --no-modify-path)
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# .NET SDK (user-level dotnet-install.sh; also used by the C# and Bicep language servers)
if [ -x "$HOME/.dotnet/dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi

# ── Windows interop (appendWindowsPath=false in /etc/wsl.conf) ───────────
WIN_HOME="$(wslpath "$(/mnt/c/Windows/System32/cmd.exe /C 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")"
alias code="'${WIN_HOME}/AppData/Local/Programs/Microsoft VS Code/bin/code'"
alias explorer="/mnt/c/Windows/explorer.exe"
alias clip="/mnt/c/Windows/System32/clip.exe"
alias powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# ── Aliases ──────────────────────────────────────────────────────────────
alias v="nvim"
alias ll="ls -alFh"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -20"
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init - zsh)"

# BEGIN Agency MANAGED BLOCK
if [[ ":${PATH}:" != *":/home/acagrawal/.config/agency/CurrentVersion:"* ]]; then
    export PATH="/home/acagrawal/.config/agency/CurrentVersion:${PATH}"
fi
# END Agency MANAGED BLOCK
