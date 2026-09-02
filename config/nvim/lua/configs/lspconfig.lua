require("nvchad.configs.lspconfig").defaults()

local servers = { "astro", "bashls", "jsonls", "tailwindcss", "ts_ls", "biome" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
