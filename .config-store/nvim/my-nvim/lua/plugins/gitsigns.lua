local _signs = {
  add = { text = "▎" },
  change = { text = "▎" },
  delete = { text = "" },
  topdelete = { text = "" },
  changedelete = { text = "▎" },
  untracked = { text = "▎" },
}

require("gitsigns").setup({
  signs = _signs,
  signs_staged = _signs,
})

vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive Full Page New Tab" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set({ "n", "v" }, "<leader>gS", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Git Stage Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Git Stage Buffer" })
vim.keymap.set({ "n", "v" }, "<leader>gR", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git Reset Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>gr", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Git Reset Buffer" })
