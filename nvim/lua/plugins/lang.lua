-- Language support beyond the LazyVim `lang.*` extras enabled in lazyvim.json
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bicep",
        "c",
        "c_sharp",
        "embedded_template", -- erb
        "sql",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bicep = {},
        -- The pinned nvim-lspconfig compares cmd_cwd, which is unset on the first client, so every
        -- Ruby buffer spawned a second ruby-lsp. Same fix as upstream nvim-lspconfig.
        ruby_lsp = {
          reuse_client = function(client, config)
            config.cmd_cwd = config.root_dir
            return client.name == config.name and client.config.root_dir == config.root_dir
          end,
        },
        -- C#; the server comes from Mason's `roslyn-language-server` and needs `dotnet` on PATH
        roslyn_ls = {},
        -- ruby-lsp already runs the project's bundled RuboCop, so skip the standalone server
        rubocop = { enabled = false },
      },
    },
  },
  {
    -- v9+ requires Neovim 0.12; setup.sh installs 0.11
    "mrcjkb/rustaceanvim",
    version = vim.fn.has("nvim-0.12") == 1 and false or "^8",
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Fall back to LSP formatting (ruby-lsp → bundled RuboCop) instead of a global rubocop
      opts.formatters_by_ft.ruby = nil
    end,
  },
}
