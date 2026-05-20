vim.pack.add({
  "https://github.com/folke/which-key.nvim",
}, { confirm = false })

require("which-key").setup({
  icons = { mappings = false },
})
