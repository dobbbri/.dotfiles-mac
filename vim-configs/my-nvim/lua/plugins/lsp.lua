require("mason").setup()
require("mason-auto-install").setup({
  packages = {
    "astro-language-server",
    "bash-language-server",
    "json-lsp",
    "biome",
    "prettier",
    "shfmt",
    "stylua",
    "taplo",
    "tailwindcss-language-server",
    "lua-language-server",
    "typescript-language-server",
    "yamlfmt",
  },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
})

vim.lsp.enable({ "astro", "bashls", "jsonls", "lua_ls", "tailwindcss", "ts_ls", "biome" })

vim.keymap.set("n", "ld", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "lD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "lt", vim.lsp.buf.type_definition, { desc = "Show LSP type definition" })
vim.keymap.set("n", "lr", vim.lsp.buf.references, { desc = "Show LSP references" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation for what is under cursor" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "See available code actions" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart rename" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format Local buffer" })

-- vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Show Quickfix" })
-- vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})
