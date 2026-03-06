#!/usr/bin/env bash
# Idempotent WSL setup script — safe to run multiple times.
# Usage: bash ~/.config/setup.sh
set -euo pipefail

NVIM_VERSION="v0.11.6"
NVIM_INSTALL_DIR="/opt/nvim-linux-x86_64"
NVIM_TARBALL_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

log() { printf '\e[1;34m[setup]\e[0m %s\n' "$*"; }
ok()  { printf '\e[1;32m[setup]\e[0m %s ✓\n' "$*"; }

# ── 1. System dependencies ──────────────────────────────────────────────
log "Ensuring system packages..."
PACKAGES=(
  build-essential  # gcc/g++/make — needed for treesitter parser compilation
  git
  curl
  unzip
  ripgrep          # telescope live-grep
  fd-find          # telescope find-files
  nodejs           # treesitter CLI, LSPs
  npm
)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  log "Installing: ${MISSING[*]}"
  sudo apt-get update -qq
  sudo apt-get install -y -qq "${MISSING[@]}"
else
  ok "System packages already installed"
fi

# ── 2. Neovim ────────────────────────────────────────────────────────────
install_neovim() {
  log "Installing Neovim ${NVIM_VERSION}..."
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$NVIM_TARBALL_URL" -o "$tmp/nvim.tar.gz"
  sudo rm -rf "$NVIM_INSTALL_DIR"
  sudo mkdir -p /opt
  sudo tar -xzf "$tmp/nvim.tar.gz" -C /opt
  rm -rf "$tmp"
  ok "Neovim ${NVIM_VERSION} installed to ${NVIM_INSTALL_DIR}"
}

# Check if nvim exists and matches desired version
if command -v nvim &>/dev/null; then
  CURRENT="$(nvim --version | head -1 | awk '{print $2}')"
  if [ "$CURRENT" = "$NVIM_VERSION" ]; then
    ok "Neovim ${NVIM_VERSION} already installed"
  else
    log "Neovim version mismatch (have ${CURRENT}, want ${NVIM_VERSION})"
    install_neovim
  fi
else
  install_neovim
fi

# Ensure nvim is on PATH via /usr/local/bin symlink
if [ ! -L /usr/local/bin/nvim ] || [ "$(readlink -f /usr/local/bin/nvim)" != "${NVIM_INSTALL_DIR}/bin/nvim" ]; then
  sudo ln -sf "${NVIM_INSTALL_DIR}/bin/nvim" /usr/local/bin/nvim
  ok "Symlinked nvim → /usr/local/bin/nvim"
else
  ok "nvim symlink already correct"
fi

# ── 3. tree-sitter CLI (for nvim-treesitter parser builds) ───────────────
if command -v tree-sitter &>/dev/null; then
  ok "tree-sitter CLI already installed"
else
  log "Installing tree-sitter-cli via npm..."
  sudo npm install -g tree-sitter-cli
  ok "tree-sitter CLI installed"
fi

# ── 4. LazyVim ───────────────────────────────────────────────────────────
# The nvim/ config in this repo IS the LazyVim starter.
# lazy.nvim + plugins bootstrap themselves on first launch.
# We just need to make sure ~/.config/nvim exists (it's part of this repo).
if [ -f "${HOME}/.config/nvim/init.lua" ]; then
  ok "LazyVim config present"
else
  log "ERROR: ~/.config/nvim/init.lua not found — clone this repo into ~/.config first"
  exit 1
fi

# Headless plugin sync so first interactive launch is fast
log "Syncing LazyVim plugins (headless)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
ok "LazyVim plugins synced"

# ── 5. Summary ───────────────────────────────────────────────────────────
echo ""
ok "All done! Run 'nvim' to get started."
