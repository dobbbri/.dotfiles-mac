vim.api.nvim_create_user_command("SaveAsRoot", "w !sudo tee %", { desc = "Save current file as root (requires doas/sudo)" })

--  jump to the last place you’ve visited in a file before exiting
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "grug-far", "help", "lspinfo", "man", "notify", "qf", "query", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  -- pattern = { "json", "jsonc", "json5" },
  pattern = { "json", "json5" },
  callback = function() vim.opt_local.conceallevel = 0 end,
})

-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     -- vim.api.nvim_set_hl(0, "MiniFilesTitle", { fg = "#ffffff" })
--     -- vim.api.nvim_set_hl(0, "MiniFilesCursorLine", { bold = true, bg = "#475569" })
--     -- vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "MiniFilesBorder" })
--     -- vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", { link = "MiniFilesBorder" })
--     -- vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "MiniFilesBorder" })
--     --
--     -- vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { bold = true, bg = "#475569" })
--     -- vim.api.nvim_set_hl(0, "MiniPickBorderText", { link = "MiniPickBorder" })
--     -- vim.api.nvim_set_hl(0, "MiniPickPrompt", { link = "MiniPickBorder" })
--   end,
-- })

-- vim.opt.wildmode = "noselect"
-- vim.api.nvim_create_autocmd("CmdlineChanged", {
--   pattern = ":",
--   callback = function ()
--     vim.fn.wildtrigger()
--   end
-- })

-- get git branch name
-- vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "FocusGained" }, {
--   desc = "git branch",
--   callback = function()
--     if vim.fn.isdirectory(".git") ~= 0 then
--       vim.b.branch_name = "󰊢 " .. vim.fn.system("git branch --show-current | tr -d '\n'")
--     end
--   end,
--   group = vim.api.nvim_create_augroup("init_statusline", {}),
-- })
