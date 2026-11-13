vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "MiniFilesTitle" })
    vim.api.nvim_set_hl(0, "MiniFilesNormal", { link = "MiniFilesTitle" })
    vim.api.nvim_set_hl(0, "MiniPickNormal", { link = "MiniFilesTitle" })
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "Pmenu", { fg = "#ffffff", bg = "#2f363d" })
  end,
})

vim.cmd("colorscheme unokai")
