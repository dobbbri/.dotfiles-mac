--- save cursor postion ---
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

--- treesitter highlight ---
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "<filetype>" },
  callback = function() vim.treesitter.start() end,
})

--- TextYankPost ---
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  callback = function() vim.hl.on_yank() end,
})

--- mini.files - exit on close ---
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    -- Map <CR> to open the file and close the explorer window
    vim.keymap.set(
      "n",
      "<CR>",
      function() require("mini.files").go_in({ close_on_file = true }) end,
      { buffer = buf_id, desc = "Open file and close explorer" }
    )
  end,
})

--- colorscheme fixes ---
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "MiniPickBorder", { link = "MiniFilesBorder" })
    vim.api.nvim_set_hl(0, "MiniPickNormal", { link = "MiniFilesNormal" })
    vim.api.nvim_set_hl(0, "Directory", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "Comment", { bg = "NONE" })
    --     -- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    --     -- vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    --     -- vim.api.nvim_set_hl(0, "Pmenu", { fg = "#ffffff", bg = "#2f363d" })
  end,
})
