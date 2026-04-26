vim.pack.add({
  "https://github.com/stevearc/conform.nvim",
}, { confirm = false })

local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    sh = { "shfmt" },
    lua = { "stylua" },
    -- cpp = { "clang-format" },
    toml = { "taplo" },
    yaml = { "yamlfmt" },
    yml = { "yamlfmt" },
    astro = { "biome" },
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    css = { "biome" },
    html = { "biome" },
    json = { "biome" },
    jsonc = { "biome" },
    scss = { "biome" },
    markdown = { "biome" },
    graphql = { "biome" },
    -- xml = { "xmlformatter" },
    -- vue = { "biome" },
    -- svelte = { "biome" },
  },
  default_format_opts = {
    lsp_fallback = false,
    async = false,
    timeout_ms = 3000,
  },
})

vim.keymap.set({ "n", "v" }, "f", function() conform.format() end, { desc = "Format file" })
