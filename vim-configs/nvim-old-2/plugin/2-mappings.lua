-- general mappings
vim.keymap.set("n", "1", "<cmd>w<CR>")
vim.keymap.set("n", "2", "<cmd>q<CR>")
vim.keymap.set("i", "jk", "<ESC>")

vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

vim.keymap.set("n", ";", ":", { desc = "Enter command mode" })
vim.keymap.set("n", "<esc>", "<cmd>noh<CR>", { desc = "Clear Highlights" })
vim.keymap.set("n", "<c-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<c-S>", "<cmd>wa<CR>", { desc = "Save all file" })
vim.keymap.set("n", "<c-a>", "<cmd>ggVG<CR>", { desc = "Copy Whole File" })

-- move buffer
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>")
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>")

-- close buffer
vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>X", "<cmd>%bd<cr>", { desc = "Close all buffers" })

-- search / replace
vim.keymap.set("n", "<leader>r", ":%s///gcI<Left><Left><Left><Left><Left>", { desc = "replace in current buffer" })

-- reload
-- vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Reload buffer" })

-- Open terminal
-- vim.keymap.set("n", "<leader>t", function()
-- 	vim.cmd.term()
-- 	vim.cmd("startinsert")
-- end, { desc = "Open terminal" })
--
-- -- Exit terminal with Esc
-- vim.keymap.set("t", "<esc>", "<c-\\><c-n>")
