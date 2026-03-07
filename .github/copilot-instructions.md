# Copilot Instructions

This is a **WSL dotfiles repository** rooted at `~/.config`. It automates a development environment setup for WSL with Neovim (LazyVim), Zsh (Oh My Zsh), and supporting tools.

## Setup

```bash
# Full environment bootstrap (idempotent, safe to re-run)
bash setup.sh
```

`setup.sh` installs system packages, Neovim, tree-sitter CLI, lazygit, Oh My Zsh (with plugins), and symlinks `zsh/.zshrc` → `~/.zshrc`. It then runs a headless LazyVim plugin sync.

## Architecture

- **setup.sh** — Single entry point for bootstrapping the entire environment. All operations are idempotent.
- **nvim/** — LazyVim-based Neovim config. `init.lua` loads `config/lazy.lua` which bootstraps lazy.nvim and imports LazyVim. Custom options, keymaps, and autocmds go in `lua/config/`. Plugin specs go in `lua/plugins/`.
- **zsh/.zshrc** — Zsh config with Oh My Zsh, shell aliases, and Windows/WSL interop aliases (assumes `appendWindowsPath=false` in `/etc/wsl.conf`).

## Key Conventions

- **Whitelist gitignore**: The root `.gitignore` uses `*` to ignore everything, then explicitly whitelists tracked directories (`!nvim/`, `!zsh/`, etc.). When adding new tracked directories, you must add both `!dirname/` and `!dirname/**` entries.
- **Neovim plugins**: LazyVim starter pattern — custom plugin specs are returned as Lua tables from files in `lua/plugins/`. The included `example.lua` is disabled (`if true then return {} end`) and serves as a reference template.
- **Lua formatting**: stylua with 2-space indent, 120 column width (`nvim/stylua.toml`).
- **Shell aliases**: Defined in `zsh/.zshrc` — `v`=nvim, `gs`=git status, `gd`=git diff, `gl`=git log.
- **Symlink pattern**: Config files that need to live at specific paths (like `~/.zshrc`) are symlinked from this repo by `setup.sh`, keeping the repo as the single source of truth.
