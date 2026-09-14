-------------------------------------------------------
-- AUTOCMDS DE QUALIDADE DE VIDA (nativas, sem plugin)
-------------------------------------------------------

--- save cursor position ---
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restaurar cursor na última posição ao reabrir um arquivo",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

--- TextYankPost ---
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function() vim.hl.hl_op() end,
})

--- redimensiona os splits proporcionalmente quando a janela do terminal muda de tamanho ---
vim.api.nvim_create_autocmd("VimResized", {
  desc = "Reequilibrar splits ao redimensionar a janela",
  callback = function() vim.cmd("wincmd =") end,
})

--- fecha buffers "utilitários" só com "q" (sem precisar de :q ou <C-w>q) ---
vim.api.nvim_create_autocmd("FileType", {
  desc = "Fechar buffers utilitários (help, qf, lspinfo etc.) com 'q'",
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth", "notify", "dapui_console", "dap-repl" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
  end,
})
