vim.pack.add({
  "https://github.com/numToStr/FTerm.nvim",
}, { confirm = false })

local fterm = require("FTerm")

fterm.setup({
  hl = "MiniFilesNormal",
  dimensions = { height = 0.8, width = 0.8 },
})

vim.keymap.set("n", "<leader>t", "<cmd>lua require('FTerm').toggle()<CR>", { desc = "Terminal Toggle" })
vim.keymap.set("t", "<leader>t", "<C-\\><C-n><cmd>lua require('FTerm').toggle()<CR>", { desc = "Terminal Toggle" })
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit Terminal Mode" })

local lg = fterm:new({
  ft = "fterm_lg",
  cmd = "lazygit",
  dimensions = { height = 0.8, width = 0.8 },
})

-- Use this to toggle btop in a floating terminal
vim.keymap.set("n", "<leader>g", function() lg:toggle() end, { desc = "LazyGit Toggle" })
