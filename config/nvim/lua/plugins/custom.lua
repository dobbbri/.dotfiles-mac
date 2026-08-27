-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins

return {

  -- add servers to lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {},
        astro = {},
        bashls = {},
        jsonls = {},
        lua_ls = {},
        tailwindcss = {},
        ts_ls = {},
        biome = {},
      },
    },
  },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "http",
        "astro",
      },
    },
  },

  -- add any tools you want to have installed below
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "astro-language-server",
        "bash-language-server",
        "json-lsp",
        "biome",
        "prettier",
        "taplo",
        "tailwindcss-language-server",
        "lua-language-server",
        "typescript-language-server",
        "yamlfmt",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        lua = { "stylua" },
        toml = { "taplo" },
        yaml = { "yamlfmt" },
        astro = { "biome" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        css = { "biome" },
        html = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        markdown = { "biome" },
      },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
  },
}
